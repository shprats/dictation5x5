//
//  RecordingStore.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//


import Foundation

/// Simplified local-only persistence. Later you can sync to cloud.
/// All recordings are stored per user ID to ensure data isolation.
final class RecordingStore: ObservableObject {

    struct TranscriptRecord: Codable {
        let sessionID: String
        let userID: String
        let finalTranscript: String
        let interim: String?
        let metrics: StreamingMetricsSnapshot
        let updatedAt: Date
    }

    private let root: URL
    private let fileManager = FileManager.default
    private let ioQueue = DispatchQueue(label: "recording.store.queue", qos: .utility)
    private(set) var currentUserID: String?

    init(rootDirectoryName: String = "recordings") {
        let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        root = base.appendingPathComponent(rootDirectoryName, isDirectory: true)
        ensureDirectory(root)
    }
    
    /// Set the current user ID. All subsequent operations will be scoped to this user.
    func setUserID(_ userID: String) {
        currentUserID = userID
        ensureDirectory(userRoot(userID: userID))
    }
    
    /// Clear the current user ID (e.g., on sign out)
    func clearUserID() {
        currentUserID = nil
    }

    func listSessions(userID: String) -> [String] {
        let userDir = userRoot(userID: userID)
        guard fileManager.fileExists(atPath: userDir.path) else { return [] }
        return (try? fileManager.contentsOfDirectory(atPath: userDir.path)) ?? []
    }
    
    /// List sessions for the current user (if set)
    func listSessions() -> [String] {
        guard let userID = currentUserID else { return [] }
        return listSessions(userID: userID)
    }

    func transcript(for sessionID: String, userID: String) -> TranscriptRecord? {
        let url = transcriptURL(sessionID: sessionID, userID: userID)
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let record = try? JSONDecoder().decode(TranscriptRecord.self, from: data) else { return nil }
        // Verify the transcript belongs to the requested user
        guard record.userID == userID else { return nil }
        return record
    }
    
    /// Get transcript for current user (if set)
    func transcript(for sessionID: String) -> TranscriptRecord? {
        guard let userID = currentUserID else { return nil }
        return transcript(for: sessionID, userID: userID)
    }

    func appendRawPCM(sessionID: String, data: Data, userID: String) {
        ioQueue.async {
            let dir = self.sessionDir(sessionID: sessionID, userID: userID)
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
    
    /// Append PCM data for current user (if set)
    func appendRawPCM(sessionID: String, data: Data) {
        guard let userID = currentUserID else {
            print("[RecordingStore] Warning: Cannot append PCM data - no user ID set")
            return
        }
        appendRawPCM(sessionID: sessionID, data: data, userID: userID)
    }

    func finalizeWAV(sessionID: String, sampleRate: Int, channels: Int, bitsPerSample: Int, userID: String) throws {
        let dir = sessionDir(sessionID: sessionID, userID: userID)
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
    
    /// Finalize WAV for current user (if set)
    func finalizeWAV(sessionID: String, sampleRate: Int, channels: Int, bitsPerSample: Int) throws {
        guard let userID = currentUserID else {
            throw NSError(domain: "RecordingStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user ID set"])
        }
        try finalizeWAV(sessionID: sessionID, sampleRate: sampleRate, channels: channels, bitsPerSample: bitsPerSample, userID: userID)
    }

    func saveTranscript(sessionID: String,
                        transcript: String,
                        interim: String?,
                        metrics: StreamingMetricsSnapshot,
                        userID: String) {
        ioQueue.async {
            let record = TranscriptRecord(sessionID: sessionID,
                                          userID: userID,
                                          finalTranscript: transcript,
                                          interim: interim,
                                          metrics: metrics,
                                          updatedAt: Date())
            let dir = self.sessionDir(sessionID: sessionID, userID: userID)
            self.ensureDirectory(dir)
            let url = self.transcriptURL(sessionID: sessionID, userID: userID)
            if let data = try? JSONEncoder().encode(record) {
                try? data.write(to: url, options: .atomic)
            }
        }
    }
    
    /// Save transcript for current user (if set)
    func saveTranscript(sessionID: String,
                        transcript: String,
                        interim: String?,
                        metrics: StreamingMetricsSnapshot) {
        guard let userID = currentUserID else {
            print("[RecordingStore] Warning: Cannot save transcript - no user ID set")
            return
        }
        saveTranscript(sessionID: sessionID, transcript: transcript, interim: interim, metrics: metrics, userID: userID)
    }

    func sessionDir(sessionID: String, userID: String) -> URL {
        userRoot(userID: userID).appendingPathComponent(sessionID, isDirectory: true)
    }
    
    /// Get session directory for current user (if set)
    func sessionDir(sessionID: String) -> URL {
        guard let userID = currentUserID else {
            fatalError("Cannot get session directory without user ID")
        }
        return sessionDir(sessionID: sessionID, userID: userID)
    }
    
    private func userRoot(userID: String) -> URL {
        root.appendingPathComponent(userID, isDirectory: true)
    }

    private func transcriptURL(sessionID: String, userID: String) -> URL {
        sessionDir(sessionID: sessionID, userID: userID).appendingPathComponent("transcript.json")
    }

    private func ensureDirectory(_ url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}
