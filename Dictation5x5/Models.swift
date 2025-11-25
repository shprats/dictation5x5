//
//  Models.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//

import Foundation

struct RecordingListItem: Identifiable {
    let id: String
    let updatedAt: Date
    let transcriptPreview: String
    let durationSeconds: Double?
    let bytesSent: Int
}
