import Foundation
import AVFoundation
import Combine

final class SpeechStreamingManager: NSObject, ObservableObject {

    enum State: Equatable {
        case idle, connecting, configuring, streaming, stopping, finished, error(String)
    }

    // UI State
    @Published private(set) var state: State = .idle
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var isStopping: Bool = false
    @Published var statusText: String = "Status: Idle"
    @Published var statusSpinning: Bool = false
    @Published var showLiveIndicator: Bool = false

    // Transcript and metrics
    @Published var transcript = TranscriptModel()
    let metrics = StreamingMetrics()

    // Audio quality parameters - optimized for speech recognition
    private let targetSampleRate: Double = 16_000
    private let bytesPerSample = 2
    // Use 200ms chunks for better quality and stability (was 100ms)
    private let timesliceMs: Int = 200
    private var samplesPerChunk: Int { Int(targetSampleRate * Double(timesliceMs) / 1000.0) } // 3200 frames
    private var chunkBytes: Int { samplesPerChunk * bytesPerSample } // 6400 bytes
    private let maxServerChunkBytes: Int = 25_600
    private let sendAsWavChunks: Bool = false

    private var websocketURL: URL
    private let store: RecordingStore
    private var sessionID: String = UUID().uuidString

    // Audio
    private let audioEngine = AVAudioEngine()
    private var inputFormat: AVAudioFormat!
    private var converter: AVAudioConverter?
    private var desiredFormat: AVAudioFormat!
    private var pcmBuffer = Data()
    private var framesAccumulated: Int = 0

    // WebSocket
    private var webSocketTask: URLSessionWebSocketTask?
    private var webSocketSession: URLSession?
    private let webSocketQueue = OperationQueue()

    // Stop watchdog
    private var stopWatchdog: Timer?

    // Client-side interim regression guard
    private var lastInterim: String = ""

    private var cancellables: Set<AnyCancellable> = []

    init(websocketURL: URL, store: RecordingStore) {
        self.websocketURL = websocketURL
        self.store = store
        super.init()
    }

    // MARK: Public API

    func start() {
        guard case .idle = state else { return }
        // Ensure user ID is set before starting recording
        guard store.currentUserID != nil else {
            DispatchQueue.main.async {
                self.showError("Please sign in to record")
            }
            return
        }
        DispatchQueue.main.async {
            self.sessionID = UUID().uuidString
            self.transcript.reset()
            self.metrics.reset(sessionID: self.sessionID)
            self.setStatus("Connecting…", spinning: true)
            self.state = .connecting
            self.connectWebSocket()
        }
    }

    func stop() {
        guard isRecording, !isStopping else { return }
        DispatchQueue.main.async {
            self.isStopping = true
            self.state = .stopping
            self.setStatus("Stopping… awaiting finalization", spinning: true)
            self.showLiveIndicator = true

            self.stopAudioCapture()
            self.flushPendingPcmToServer(label: "final-flush", allowWhileStopping: true)
            self.sendString("STOP_RECORDING")
            self.stopWatchdog?.invalidate()
            self.stopWatchdog = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
                guard let self else { return }
                if self.isStopping {
                    self.transcript.commitInterimIfNoFinal()
                    self.showError("Timed out waiting for DONE.")
                    self.closeWebSocket(code: .internalServerError, reason: "Timeout")
                }
            }
        }
    }

    func reset() {
        guard !isRecording else { return }
        DispatchQueue.main.async {
            self.transcript.reset()
            self.metrics.reset(sessionID: UUID().uuidString)
            self.setStatus("Idle", spinning: false)
            self.state = .idle
            self.showLiveIndicator = false
            self.lastInterim = ""
        }
    }
    
    func updateWebSocketURL(_ url: URL) {
        guard case .idle = state else { return }
        websocketURL = url
        debugPrint("[SSM] WebSocket URL updated to:", url.absoluteString)
    }

    // MARK: - WebSocket

    private func connectWebSocket() {
        webSocketQueue.qualityOfService = .userInitiated
        let config = URLSessionConfiguration.default
        webSocketSession = URLSession(configuration: config, delegate: self, delegateQueue: webSocketQueue)
        webSocketTask = webSocketSession?.webSocketTask(with: websocketURL)
        webSocketTask?.resume()
        receiveLoop()
    }

    private func sendString(_ text: String) {
        debugPrint("[SSM] sendString:", text)
        webSocketTask?.send(.string(text)) { [weak self] error in
            if let e = error {
                DispatchQueue.main.async {
                    debugPrint("[SSM] sendString error:", e.localizedDescription)
                    self?.handleReceiveError("Send error: \(e.localizedDescription)")
                }
            }
        }
    }

    private func receiveLoop() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                DispatchQueue.main.async {
                    debugPrint("[SSM] WS receive error:", err.localizedDescription)
                    self.handleReceiveError(err.localizedDescription)
                }
            case .success(let message):
                // Immediately re-arm receive to avoid backpressure
                self.receiveLoop()
                DispatchQueue.main.async {
                    debugPrint("[SSM] WS message:", message)
                    self.handleServerMessage(message)
                }
            }
        }
    }

    private func handleReceiveError(_ message: String) {
        if isStopping && (
            message.contains("Socket is not connected") ||
            message.contains("Receive failure")
        ) {
            debugPrint("[SSM] WS receive error after stop -- treating as normal close")
            self.transcript.commitInterimIfNoFinal()
            self.finalizeAndClose(after: 0.2)
            return
        }
        self.transcript.commitInterimIfNoFinal()
        showError("WebSocket receive error: \(message)")
        closeWebSocket(code: .goingAway, reason: "Receive failure")
    }

    private func handleServerMessage(_ msg: URLSessionWebSocketTask.Message) {
        guard case .string(let line) = msg else { return }
        debugPrint("[SSM] handle line:", line)

        if line.hasPrefix("INTERIM:") {
            // INTERIM is cumulative (full hypothesis). Guard against large regression to avoid wipes.
            let hyp = String(line.dropFirst(8)).trimmingCharacters(in: .whitespacesAndNewlines)
            debugPrint("[SSM] Received INTERIM (len=\(hyp.count)):", hyp.prefix(100))
            if self.metrics.firstInterimAt == nil { self.metrics.markFirstInterim() }

            // Allow small fluctuations; ignore large shrink
            let allow = hyp.count + 4 >= lastInterim.count || lastInterim.isEmpty
            if allow {
                self.lastInterim = hyp
                self.transcript.mergeInterimCandidate(hyp)
                debugPrint("[SSM] Updated interim transcript")
            } else {
                // ignore regressive interim
                debugPrint("[SSM] Ignoring regressive interim (len:", hyp.count, "< last:", lastInterim.count, ")")
            }

        } else if line.hasPrefix("FINAL:") {
            let nextFull = String(line.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
            debugPrint("[SSM] Received FINAL (len=\(nextFull.count)):", nextFull.prefix(100))
            self.transcript.handleFinal(nextFull)
            self.lastInterim = ""
            self.setStatus(isStopping ? "Final received… waiting DONE" : "Receiving finals…", spinning: false)

        } else if line == "ACK: STOP_RECEIVED" {
            self.setStatus("Stop acknowledged… refining final", spinning: true)

        } else if line == "DONE" {
            // Commit last interim if we never got a final
            self.transcript.commitInterimIfNoFinal()
            if let sw = self.stopWatchdog { sw.invalidate(); self.stopWatchdog = nil }
            self.setStatus("Complete.", spinning: false)
            self.finalizeAndClose(after: 0.35)

        } else if line.hasPrefix("ERROR:") {
            let body = String(line.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
            self.transcript.commitInterimIfNoFinal()
            self.showError(body)
            self.closeWebSocket(code: .internalServerError, reason: "Server error")
        }
    }

    private func finalizeAndClose(after delay: TimeInterval) {
        self.finalizeAudioFile()
        self.metrics.markSessionEnd()
        self.persistSessionMetadata()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.closeWebSocket(code: .normalClosure, reason: "Client closing after DONE")
        }
    }

    private func closeWebSocket(code: URLSessionWebSocketTask.CloseCode, reason: String) {
        debugPrint("[SSM] WS close:", reason, "code:", code.rawValue)
        webSocketTask?.cancel(with: code, reason: reason.data(using: .utf8))
        webSocketSession?.invalidateAndCancel()
        webSocketTask = nil
        DispatchQueue.main.async {
            self.isRecording = false
            self.isStopping = false
            self.showLiveIndicator = false
            if case .stopping = self.state { self.state = .finished }
        }
    }

    // MARK: Audio

    private func sendConfigAndStartAudio() {
        DispatchQueue.main.async {
            self.state = .configuring
            self.setStatus("Configuring…", spinning: true)
            self.sendString("CONFIG_ENCODING:LINEAR16")
            debugPrint("[SSM] Sent CONFIG_ENCODING:LINEAR16")

            self.configureAudioSession()
            self.setupAndStartEngine()

            self.state = .streaming
            self.setStatus("Listening…", spinning: false)
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Use .spokenAudio mode for better speech recognition quality
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.duckOthers, .allowBluetooth, .defaultToSpeaker])
            // Use 10ms buffer for better quality (was 20ms)
            try session.setPreferredIOBufferDuration(0.01)
            try session.setPreferredSampleRate(targetSampleRate)
            try session.setActive(true)
            debugPrint("[SSM] Audio session configured target SR:", targetSampleRate, "mode: spokenAudio")
        } catch {
            transitionToError("Audio session error: \(error)")
        }
    }

    private func setupAndStartEngine() {
        let inputNode = audioEngine.inputNode
        inputFormat = inputNode.outputFormat(forBus: 0)
        desiredFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: targetSampleRate, channels: 1, interleaved: false)
        guard let desiredFormat else {
            transitionToError("Failed creating desired audio format.")
            return
        }
        converter = AVAudioConverter(from: inputFormat, to: desiredFormat)

        debugPrint("[SSM] Input SR:", inputFormat.sampleRate, "ch:", inputFormat.channelCount,
                   "→ Target SR:", desiredFormat.sampleRate, "ch:", desiredFormat.channelCount)

        inputNode.removeTap(onBus: 0)
        // Use larger buffer (50ms) for better audio quality and stability
        let frameCapacity = AVAudioFrameCount(max(1024, Int(inputFormat.sampleRate * 0.05)))
        inputNode.installTap(onBus: 0, bufferSize: frameCapacity, format: inputFormat) { [weak self] buffer, _ in
            self?.processIncomingBuffer(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
                self.showLiveIndicator = true
                self.setStatus("Listening…", spinning: false)
            }
            debugPrint("[SSM] Audio engine started")
        } catch {
            transitionToError("Engine start failed: \(error)")
        }
    }

    private func processIncomingBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let converter, let desiredFormat else { return }
        // Use larger buffer (100ms) for better quality and stability
        guard let outBuf = AVAudioPCMBuffer(pcmFormat: desiredFormat,
                                            frameCapacity: AVAudioFrameCount(Int(desiredFormat.sampleRate * 0.1))) else { return }

        var consumed = false
        var conversionError: NSError?
        let status = converter.convert(to: outBuf, error: &conversionError) { _, outStatus in
            if consumed { outStatus.pointee = .noDataNow; return nil }
            consumed = true
            outStatus.pointee = .haveData
            return buffer
        }
        
        if status == .error {
            debugPrint("[SSM] Converter error:", conversionError?.localizedDescription ?? "unknown")
            return
        }
        
        if status == .haveData && outBuf.frameLength == 0 {
            // No data converted, skip
            return
        }

        let frameCount = Int(outBuf.frameLength)
        guard frameCount > 0, let mono = outBuf.floatChannelData?.pointee else { return }

        // Convert Float32 to Int16 with proper scaling and clamping
        var int16Data = Data(capacity: frameCount * bytesPerSample)
        int16Data.reserveCapacity(frameCount * bytesPerSample)
        
        for i in 0..<frameCount {
            // Clamp to valid range and convert to Int16
            let floatSample = max(-1.0, min(1.0, mono[i]))
            // Use 32767 for full scale (not 32768 to avoid overflow)
            let int16Sample = Int16(floatSample * 32767.0)
            // Append as little-endian bytes
            var sample = int16Sample.littleEndian
            withUnsafeBytes(of: &sample) { bytes in
                int16Data.append(contentsOf: bytes)
            }
        }

        pcmBuffer.append(int16Data)
        framesAccumulated += frameCount
        
        // Save audio locally for playback
        store.appendRawPCM(sessionID: sessionID, data: int16Data)
        
        emitChunksIfReady()
    }

    private func emitChunksIfReady() {
        let chunkSize = min(chunkBytes, maxServerChunkBytes)
        while pcmBuffer.count >= chunkSize {
            let slice = pcmBuffer.prefix(chunkSize)
            pcmBuffer.removeFirst(chunkSize)
            framesAccumulated = max(0, framesAccumulated - (chunkSize / bytesPerSample))
            debugPrint("[SSM] Sending RAW PCM bytes:", slice.count)
            sendAudioChunk(slice, allowWhileStopping: false)
        }
    }

    private func flushPendingPcmToServer(label: String, allowWhileStopping: Bool) {
        let chunkSize = min(chunkBytes, maxServerChunkBytes)
        while !pcmBuffer.isEmpty {
            let n = min(pcmBuffer.count, chunkSize)
            let slice = pcmBuffer.prefix(n)
            pcmBuffer.removeFirst(n)
            framesAccumulated = max(0, framesAccumulated - (n / bytesPerSample))
            debugPrint("[SSM] Flushing RAW PCM bytes:", slice.count, "label:", label)
            sendAudioChunk(slice, allowWhileStopping: allowWhileStopping)
        }
    }

    private func sendAudioChunk(_ pcmData: Data, allowWhileStopping: Bool) {
        let canSend: Bool
        switch state {
        case .streaming: canSend = true
        case .stopping:  canSend = allowWhileStopping
        default:         canSend = false
        }
        guard canSend else {
            debugPrint("[SSM] Skipping send (state =", state, ") bytes:", pcmData.count)
            return
        }

        let payload = pcmData
        metrics.addBytesSent(payload.count)
        webSocketTask?.send(.data(payload)) { [weak self] error in
            if let e = error {
                DispatchQueue.main.async {
                    debugPrint("[SSM] sendAudioChunk error:", e.localizedDescription)
                    self?.handleReceiveError("Send error: \(e.localizedDescription)")
                }
            }
        }
    }

    private func stopAudioCapture() {
        audioEngine.inputNode.removeTap(onBus: 0)
        if audioEngine.isRunning {
            audioEngine.stop()
        }
    }

    // MARK: Persistence

    private func finalizeAudioFile() {
        do {
            try store.finalizeWAV(sessionID: sessionID, sampleRate: Int(targetSampleRate), channels: 1, bitsPerSample: 16)
            debugPrint("[SSM] WAV finalized at", Int(targetSampleRate), "Hz")
        } catch {
            debugPrint("[SSM] WAV finalize error:", error.localizedDescription)
        }
    }

    private func persistSessionMetadata() {
        store.saveTranscript(sessionID: sessionID,
                             transcript: transcript.finalTranscript,
                             interim: nil,
                             metrics: metrics.snapshot())
        debugPrint("[SSM] Persisted session metadata")
    }

    private func setStatus(_ message: String, spinning: Bool) {
        statusText = "Status: " + message
        statusSpinning = spinning
        debugPrint("[SSM] Status:", statusText)
    }

    private func showError(_ message: String) {
        state = .error(message)
        isRecording = false
        isStopping = false
        showLiveIndicator = false
        statusText = "Status: Error"
        statusSpinning = false
        transcript.cancelHighlight()
        debugPrint("[SSM] Error:", message)
    }

    private func transitionToError(_ message: String) {
        showError(message)
        closeWebSocket(code: .internalServerError, reason: "Client error")
    }
}

// MARK: - URLSessionWebSocketDelegate
extension SpeechStreamingManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol `protocol`: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            debugPrint("[SSM] WS didOpen")
            self.sendConfigAndStartAudio()
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let reasonStr = reason.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            debugPrint("[SSM] WS didClose code:", closeCode.rawValue, "reason:", reasonStr)
            self.isRecording = false
            self.showLiveIndicator = false
            if case .stopping = self.state { self.state = .finished }
        }
    }
}
