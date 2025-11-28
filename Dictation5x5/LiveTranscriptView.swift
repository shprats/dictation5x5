//
//  LiveTranscriptView.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//

import SwiftUI

struct LiveTranscriptView: View {
    @ObservedObject var transcript: TranscriptModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        // Committed prefix - observe finalTranscript directly to ensure updates
                        Text(transcript.committedPrefixForRender)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("committed-\(transcript.finalTranscript.count)-\(transcript.changeTick)")

                        // Delta highlight (temporary flash)
                        if !transcript.committedDeltaForRender.isEmpty {
                            Text(transcript.committedDeltaForRender)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.yellow.opacity(transcript.highlightActive ? 0.7 : 0.0))
                                )
                                .animation(.easeInOut(duration: transcript.highlightActive ? 0.2 : 0.2), value: transcript.highlightActive)
                        }

                        // Ghost tail - observe interimFull directly to ensure updates after pauses
                        // The .id() modifier uses both interimFull and changeTick to force re-renders
                        if !transcript.ghostTailForRender.isEmpty {
                            HStack(spacing: 0) {
                                Text(transcript.needsSpaceBetweenCommittedAndGhost() ? " " : "")
                                    .foregroundColor(.clear)
                                Text(transcript.ghostTailForRender)
                                    .foregroundColor(Color.gray)
                                    .italic()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // Use a more unique ID that includes both interim and final to force updates
                            .id("ghost-\(transcript.interimFull.hashValue)-\(transcript.finalTranscript.count)-\(transcript.changeTick)")
                        }

                        // Empty prompt
                        if transcript.finalTranscript.isEmpty && transcript.interimFull.isEmpty {
                            Text("Say something…")
                                .foregroundColor(Color.gray.opacity(0.7))
                        }

                        // Anchor for auto-scroll
                        Color.clear.frame(height: 0).id("bottom")
                    }
                    .padding(12)
                    .onChange(of: transcript.changeTick) { _ in
                        // Force view update when tick changes
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    // Also observe interimFull and finalTranscript directly to force updates
                    // These onChange handlers ensure the view updates even after pauses
                    .onChange(of: transcript.interimFull) { newValue in
                        // Force UI refresh when interim changes - this is critical after pauses
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: transcript.finalTranscript) { newValue in
                        // Force UI refresh when final changes
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
            }

            // Toolbar (bottom-right)
            HStack(spacing: 14) {
                // Placeholder for external stats if needed
            }
            .font(.system(size: 11, weight: .regular, design: .monospaced))
            .foregroundColor(Color.gray)
            .padding(6)
            .background(Color.white.opacity(0.75))
            .cornerRadius(6)
            .padding(.trailing, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground)) // <-- PATCHED for adaptive contrast
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.systemGray4))
        )
    }
}
