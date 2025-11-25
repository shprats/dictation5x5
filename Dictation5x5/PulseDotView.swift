//
//  PulseDotView.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//


import SwiftUI

struct PulseDotView: View {
    var stopping: Bool

    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(stopping ? Color.yellow : Color.green)
                .frame(width: 11, height: 11)
            Circle()
                .strokeBorder(Color.clear)
                .background(
                    Circle()
                        .fill((stopping ? Color.yellow.opacity(0.45) : Color.green.opacity(0.45)))
                        .scaleEffect(animate ? 2.4 : 1.0)
                        .opacity(animate ? 0 : 0.9)
                )
                .frame(width: 11, height: 11)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: false)) {
                        animate = true
                    }
                }
        }
        .accessibilityLabel(stopping ? "Stopping…" : "Live")
    }
}