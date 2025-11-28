import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var store = RecordingStore()
    @StateObject private var serverConfig = ServerConfig()
    @StateObject private var streaming: SpeechStreamingManager
    @State private var showHistory = false
    @State private var showSettings = false
    
    init() {
        // Initialize with placeholder URL - will be updated when serverConfig loads
        let placeholderURL = URL(string: "ws://localhost:8080")!
        let store = RecordingStore()
        _store = StateObject(wrappedValue: store)
        _streaming = StateObject(wrappedValue: SpeechStreamingManager(
            websocketURL: placeholderURL,
            store: store
        ))
    }

    var body: some View {
        Group {
            if authManager.isSignedIn {
                mainContentView
            } else {
                LoginView(authManager: authManager)
            }
        }
    }
    
    private var mainContentView: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 16) {
                    Text("Live Transcript")
                        .font(.title)
                        .foregroundColor(.brandBlue)
                        .bold()

                    // Controls
                    HStack(spacing: 12) {
                        Button {
                            updateStreamingManagerURL()
                            streaming.start()
                        } label: {
                            Label("Start", systemImage: "play.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brandOrange)
                        .disabled(streaming.state != .idle)

                        Button {
                            streaming.stop()
                        } label: {
                            Label("Stop", systemImage: "stop.circle.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.brandBlue)
                        .disabled(!streaming.isRecording || streaming.isStopping)

                        Button {
                            streaming.reset()
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise.circle")
                        }
                        .buttonStyle(.bordered)
                        .tint(.brandBlue)
                        .disabled(streaming.isRecording)
                    }

                    // Status line + spinner
                    HStack(spacing: 8) {
                        if streaming.statusSpinning {
                            ProgressView().scaleEffect(0.8, anchor: .center)
                        }
                        Text(streaming.statusText)
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Spacer()
                    }

                    ZStack(alignment: .bottomTrailing) {
                        LiveTranscriptView(transcript: streaming.transcript)
                            .frame(minHeight: 250)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.brandOrange.opacity(0.3), lineWidth: 1)
                            )

                        HStack(spacing: 14) {
                            if streaming.showLiveIndicator {
                                PulseDotView(stopping: streaming.isStopping)
                            }
                            Text(streaming.transcript.finalRevisions > 0 ? "Final revisions: \(streaming.transcript.finalRevisions)" : "")
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.75))
                        .cornerRadius(6)
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                    }

                    Spacer()
                }
                .padding()
                .navigationBarHidden(true)
            }

            // FAB buttons at bottom right
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    Spacer()
                    // Settings button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.brandOrange)
                            .clipShape(Circle())
                            .shadow(color: .brandOrange.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel("Settings")
                    
                    // History button
                    Button(action: {
                        showHistory = true
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.brandBlue)
                            .clipShape(Circle())
                            .shadow(color: .brandBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel("History")
                    .padding(.trailing, 22)
                    .padding(.bottom, 28)
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            RecordingListView(store: store)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(authManager: authManager, serverConfig: serverConfig, streaming: streaming)
        }
        .onAppear {
            updateStreamingManagerURL()
        }
        .onChange(of: serverConfig.serverURL) { _ in
            updateStreamingManagerURL()
        }
    }
    
    private func updateStreamingManagerURL() {
        // Only update URL if not currently recording
        guard streaming.state == .idle else { return }
        streaming.updateWebSocketURL(serverConfig.serverURL)
    }
}
