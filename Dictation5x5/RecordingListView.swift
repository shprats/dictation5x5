import SwiftUI
import AVFoundation

struct PlaybackError: Identifiable {
    let id = UUID()
    let message: String
}

struct RecordingGroup: Identifiable {
    let id: String // date string
    let date: Date
    let items: [RecordingListItem]
}

struct RecordingListView: View {
    let store: RecordingStore
    @State private var sessions: [RecordingListItem] = []
    @State private var groupedSessions: [RecordingGroup] = []
    @State private var selectedDetailItem: RecordingDetailItem?
    @State private var playingSessionID: String?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playbackError: PlaybackError?

    var body: some View {
        NavigationView {
            Group {
                if store.currentUserID == nil {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Not Signed In")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Please sign in to view your recordings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if groupedSessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "mic.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Recordings")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Your recordings will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(groupedSessions) { group in
                            Section(header: Text(groupDateHeader(group.date))) {
                                ForEach(group.items) { item in
                                    RecordingRow(
                                        item: item,
                                        isPlaying: playingSessionID == item.id,
                                        onPlay: { playAudio(for: item.id) },
                                        onTap: { selectedDetailItem = RecordingDetailItem(id: item.id) }
                                    )
                                }
                            }
                        }
                    }
                    .sheet(item: $selectedDetailItem) { detailItem in
                        NavigationView {
                            RecordingDetailView(store: store, sessionID: detailItem.id)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                if store.currentUserID != nil {
                    Button("Refresh") { load() }
                }
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
        groupSessions()
    }
    
    private func groupSessions() {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.updatedAt)
        }
        
        groupedSessions = grouped.map { (date, items) in
            RecordingGroup(id: dateFormatter.string(from: date), date: date, items: items.sorted { $0.updatedAt > $1.updatedAt })
        }.sorted { $0.date > $1.date }
    }
    
    private func groupDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.dateInterval(of: .weekOfYear, for: now)?.contains(date) == true {
            return dateFormatter.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        } else {
            return dateFormatter.string(from: date)
        }
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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct RecordingRow: View {
    let item: RecordingListItem
    let isPlaying: Bool
    let onPlay: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(timeString(item.updatedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if let dur = item.durationSeconds {
                        Text(String(format: "%.1fs", dur))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(item.transcriptPreview)
                    .lineLimit(3)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("\(item.bytesSent) bytes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: onPlay) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .foregroundColor(isPlaying ? .brandOrange : .brandBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct RecordingDetailItem: Identifiable {
    let id: String
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
