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
                        // Committed prefix
                        Text(transcript.committedPrefixForRender)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

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

                        // Ghost tail
                        if !transcript.ghostTailForRender.isEmpty {
                            HStack(spacing: 0) {
                                Text(transcript.needsSpaceBetweenCommittedAndGhost() ? " " : "")
                                    .foregroundColor(.clear)
                                Text(transcript.ghostTailForRender)
                                    .foregroundColor(Color.gray)
                                    .italic()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
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
