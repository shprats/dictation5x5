import SwiftUI
import AVFoundation

struct PlaybackError: Identifiable {
    let id = UUID()
    let message: String
}

struct RecordingListView: View {
    let store: RecordingStore
    @State private var sessions: [RecordingListItem] = []
    @State private var playingSessionID: String?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playbackError: PlaybackError?

    var body: some View {
        NavigationView {
            List(sessions) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.id)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Updated: \(formattedDate(item.updatedAt))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(item.transcriptPreview)
                        .lineLimit(5)
                        .font(.body)
                        .foregroundColor(.primary)
                    HStack {
                        if let dur = item.durationSeconds {
                            Text(String(format: "Dur: %.1fs", dur))
                                .font(.caption2)
                        }
                        Text("Bytes: \(item.bytesSent)")
                            .font(.caption2)
                        Spacer()
                        Button {
                            playAudio(for: item.id)
                        } label: {
                            Label("Play", systemImage: playingSessionID == item.id ? "stop.fill" : "play.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(playingSessionID == item.id ? .brandOrange : .brandBlue)
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("History")
            .toolbar {
                Button("Refresh") { load() }
            }
            .onAppear { load() }
            .alert(item: $playbackError) { err in
                Alert(title: Text("Playback Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func load() {
        let ids = store.listSessions()
        var items: [RecordingListItem] = []
        for id in ids {
            if let rec = store.transcript(for: id) {
                let preview = rec.finalTranscript.isEmpty ? (rec.interim ?? "") : rec.finalTranscript
                items.append(.init(id: rec.sessionID,
                                   updatedAt: rec.updatedAt,
                                   transcriptPreview: preview,
                                   durationSeconds: rec.metrics.totalDurationSeconds,
                                   bytesSent: rec.metrics.bytesSent))
            }
        }
        sessions = items.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func playAudio(for sessionID: String) {
        if playingSessionID == sessionID, let player = audioPlayer, player.isPlaying {
            player.stop()
            playingSessionID = nil
            return
        }
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
            playingSessionID = sessionID
            player.delegate = AVAudioPlayerDelegateProxy(playingSessionID: $playingSessionID)
        } catch {
            playbackError = PlaybackError(message: "Failed to play audio: \(error.localizedDescription)")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Helper to auto-clear playingSessionID at end of playback
class AVAudioPlayerDelegateProxy: NSObject, AVAudioPlayerDelegate {
    @Binding var playingSessionID: String?

    init(playingSessionID: Binding<String?>) {
        self._playingSessionID = playingSessionID
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingSessionID = nil
    }
}
