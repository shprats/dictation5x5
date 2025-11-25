//
//  RecordingStore.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//


import Foundation

/// Simplified local-only persistence. Later you can sync to cloud.
final class RecordingStore: ObservableObject {

    struct TranscriptRecord: Codable {
        let sessionID: String
        let finalTranscript: String
        let interim: String?
        let metrics: StreamingMetricsSnapshot
        let updatedAt: Date
    }

    private let root: URL
    private let fileManager = FileManager.default
    private let ioQueue = DispatchQueue(label: "recording.store.queue", qos: .utility)

    init(rootDirectoryName: String = "recordings") {
        let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        root = base.appendingPathComponent(rootDirectoryName, isDirectory: true)
        ensureDirectory(root)
    }

    func listSessions() -> [String] {
        (try? fileManager.contentsOfDirectory(atPath: root.path)) ?? []
    }

    func transcript(for sessionID: String) -> TranscriptRecord? {
        let url = transcriptURL(sessionID: sessionID)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(TranscriptRecord.self, from: data)
    }

    func appendRawPCM(sessionID: String, data: Data) {
        ioQueue.async {
            let dir = self.sessionDir(sessionID: sessionID)
            self.ensureDirectory(dir)
            let raw = dir.appendingPathComponent("audio.pcm")
            if !self.fileManager.fileExists(atPath: raw.path) {
                self.fileManager.createFile(atPath: raw.path, contents: nil)
            }
            if let handle = try? FileHandle(forWritingTo: raw) {
                defer { try? handle.close() }
                handle.seekToEndOfFile()
                handle.write(data)
            }
        }
    }

    func finalizeWAV(sessionID: String, sampleRate: Int, channels: Int, bitsPerSample: Int) throws {
        let dir = sessionDir(sessionID: sessionID)
        let raw = dir.appendingPathComponent("audio.pcm")
        let wav = dir.appendingPathComponent("audio.wav")
        guard fileManager.fileExists(atPath: raw.path) else { return }
        let pcmData = try Data(contentsOf: raw)
        let wavData = WAVFileWriter.wrapPCMAsWAV(pcmData: pcmData,
                                                 sampleRate: sampleRate,
                                                 channels: channels,
                                                 bitsPerSample: bitsPerSample)
        try wavData.write(to: wav, options: .atomic)
    }

    func saveTranscript(sessionID: String,
                        transcript: String,
                        interim: String?,
                        metrics: StreamingMetricsSnapshot) {
        ioQueue.async {
            let record = TranscriptRecord(sessionID: sessionID,
                                          finalTranscript: transcript,
                                          interim: interim,
                                          metrics: metrics,
                                          updatedAt: Date())
            let dir = self.sessionDir(sessionID: sessionID)
            self.ensureDirectory(dir)
            let url = self.transcriptURL(sessionID: sessionID)
            if let data = try? JSONEncoder().encode(record) {
                try? data.write(to: url, options: .atomic)
            }
        }
    }

    func sessionDir(sessionID: String) -> URL {
        root.appendingPathComponent(sessionID, isDirectory: true)
    }

    private func transcriptURL(sessionID: String) -> URL {
        sessionDir(sessionID: sessionID).appendingPathComponent("transcript.json")
    }

    private func ensureDirectory(_ url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}
