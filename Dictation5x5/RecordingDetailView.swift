import SwiftUI
import AVFoundation

struct RecordingDetailView: View {
    let store: RecordingStore
    let sessionID: String
    @State private var transcriptRecord: RecordingStore.TranscriptRecord?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying: Bool = false
    @State private var playbackError: PlaybackError?
    @State private var showCopyConfirmation: Bool = false
    @State private var isOrganizing: Bool = false
    @State private var organizedNote: OrganizedNote?
    @State private var showOrganizedNote: Bool = false
    @State private var organizationError: String?
    @ObservedObject private var profileConfig = UserProfileConfig.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with session info
                VStack(alignment: .leading, spacing: 8) {
                    if let record = transcriptRecord {
                        Text("Session Details")
                            .font(.headline)
                            .foregroundColor(.brandBlue)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formattedDate(record.updatedAt))
                                    .font(.subheadline)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Duration")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(durationString(for: record.metrics))
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Playback controls
                        HStack {
                            Button {
                                togglePlayback()
                            } label: {
                                HStack {
                                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                    Text(isPlaying ? "Stop" : "Play Audio")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isPlaying ? Color.brandOrange : Color.brandBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        
                        Divider()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Full transcript
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript")
                        .font(.headline)
                        .foregroundColor(.brandBlue)
                    
                    if let record = transcriptRecord {
                        let fullText = record.finalTranscript.isEmpty ? (record.interim ?? "No transcript available") : record.finalTranscript
                        
                        Text(fullText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            // AI Organize button
                            Button {
                                organizeWithAI()
                            } label: {
                                HStack {
                                    if isOrganizing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "sparkles")
                                    }
                                    Text(isOrganizing ? "Organizing..." : "Organize with AI")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isOrganizing ? Color.gray : Color.brandOrange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(isOrganizing)
                            
                            // Copy button
                            Button {
                                copyTranscript()
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Transcript")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brandBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding()
                
                // Metrics
                if let record = transcriptRecord {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Metrics")
                            .font(.headline)
                            .foregroundColor(.brandBlue)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            MetricRow(label: "Bytes Sent", value: "\(record.metrics.bytesSent)")
                            MetricRow(label: "Duration", value: durationString(for: record.metrics))
                            MetricRow(label: "Session ID", value: record.sessionID)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Recording Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    copyTranscript()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadTranscript()
        }
        .onDisappear {
            stopPlayback()
        }
        .alert(item: $playbackError) { err in
            Alert(title: Text("Playback Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
        }
        .alert("Copied!", isPresented: $showCopyConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Transcript copied to clipboard")
        }
        .alert("Organization Error", isPresented: .constant(organizationError != nil)) {
            Button("OK", role: .cancel) {
                organizationError = nil
            }
        } message: {
            if let error = organizationError {
                Text(error)
            }
        }
        .sheet(isPresented: $showOrganizedNote) {
            if let organized = organizedNote {
                OrganizedNoteView(organizedNote: organized)
            }
        }
    }
    
    private func loadTranscript() {
        transcriptRecord = store.transcript(for: sessionID)
    }
    
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        let wavURL = store.sessionDir(sessionID: sessionID).appendingPathComponent("audio.wav")
        guard FileManager.default.fileExists(atPath: wavURL.path) else {
            playbackError = PlaybackError(message: "No audio recording found.")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: wavURL)
            player.prepareToPlay()
            player.play()
            audioPlayer = player
            isPlaying = true
            player.delegate = AVAudioPlayerDelegateProxyForDetail(isPlaying: $isPlaying)
        } catch {
            playbackError = PlaybackError(message: "Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func durationString(for metrics: StreamingMetricsSnapshot) -> String {
        // First try to use totalDurationSeconds
        if let dur = metrics.totalDurationSeconds, dur > 0 {
            return String(format: "%.1f seconds", dur)
        }
        
        // Fall back to calculating from startTime and endTime
        if let start = metrics.startTime {
            let end = metrics.endTime ?? Date()
            let duration = end.timeIntervalSince(start)
            if duration > 0 {
                return String(format: "%.1f seconds", duration)
            }
        }
        
        return "N/A"
    }
    
    private func copyTranscript() {
        guard let record = transcriptRecord else { return }
        
        let fullText = record.finalTranscript.isEmpty ? (record.interim ?? "No transcript available") : record.finalTranscript
        
        UIPasteboard.general.string = fullText
        showCopyConfirmation = true
    }
    
    private func organizeWithAI() {
        guard let record = transcriptRecord else { return }
        
        let fullText = record.finalTranscript.isEmpty ? (record.interim ?? "") : record.finalTranscript
        guard !fullText.isEmpty else {
            organizationError = "No transcript available to organize"
            return
        }
        
        isOrganizing = true
        let rules = profileConfig.getOrganizationRules()
        
        AINoteOrganizer.organize(transcript: fullText, rules: rules) { [self] result in
            DispatchQueue.main.async {
                isOrganizing = false
                switch result {
                case .success(let organized):
                    organizedNote = organized
                    showOrganizedNote = true
                case .failure(let error):
                    organizationError = "Failed to organize note: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// Helper to auto-clear isPlaying at end of playback
class AVAudioPlayerDelegateProxyForDetail: NSObject, AVAudioPlayerDelegate {
    @Binding var isPlaying: Bool

    init(isPlaying: Binding<Bool>) {
        self._isPlaying = isPlaying
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

