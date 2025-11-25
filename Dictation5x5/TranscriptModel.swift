import Foundation
import Combine

final class TranscriptModel: ObservableObject {
    @Published private(set) var finalTranscript: String = ""
    @Published private(set) var interimFull: String = ""
    @Published private(set) var prevFinalTranscript: String = ""
    @Published private(set) var finalRevisions: Int = 0
    @Published private(set) var highlightDelta: String? = nil
    @Published private(set) var highlightActive: Bool = false
    let highlightDuration: TimeInterval = 1.1
    private var highlightTimer: Timer?
    @Published private(set) var changeTick: Int = 0

    func reset() {
        finalTranscript = ""
        prevFinalTranscript = ""
        interimFull = ""
        finalRevisions = 0
        cancelHighlight()
        bumpTick()
    }

    /// Always REPLACE interim, never append, to avoid repetition.
    func mergeInterimCandidate(_ newHypRaw: String) {
        let newHyp = newHypRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newHyp.isEmpty else { return }
        interimFull = newHyp
        bumpTick()
    }

    /// When a final arrives, REPLACE the committed transcript and clear interim.
    /// This matches server.py behavior (FINAL is full transcript so far, not just new segment).
    func handleFinal(_ nextFullRaw: String) {
        let nextFull = nextFullRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        prevFinalTranscript = finalTranscript
        finalTranscript = nextFull  // REPLACE, do not append!
        interimFull = ""
        finalRevisions += 1

        let delta: String
        if finalTranscript.hasPrefix(prevFinalTranscript) {
            delta = String(finalTranscript.dropFirst(prevFinalTranscript.count))
        } else {
            delta = finalTranscript
            prevFinalTranscript = ""
        }

        cancelHighlight()
        if !delta.isEmpty {
            highlightDelta = delta
            highlightActive = true
            highlightTimer = Timer.scheduledTimer(withTimeInterval: highlightDuration, repeats: false) { [weak self] _ in
                guard let self else { return }
                self.highlightActive = false
                self.highlightDelta = nil
                self.bumpTick()
            }
        }
        bumpTick()
    }

    /// Call this on error or stop to preserve the last interim as the transcript (if no final)
    func commitInterimIfNoFinal() {
        if !interimFull.isEmpty {
            finalTranscript = interimFull
            interimFull = ""
            bumpTick()
        }
    }

    func cancelHighlight() {
        highlightTimer?.invalidate()
        highlightTimer = nil
        highlightActive = false
        highlightDelta = nil
    }

    // Two-tone for committed transcript rendering
    var committedPrefixForRender: String {
        if highlightActive, highlightDelta != nil {
            return prevFinalTranscript
        }
        return finalTranscript
    }

    var committedDeltaForRender: String {
        if highlightActive, let d = highlightDelta {
            return d
        }
        return ""
    }

    // Full transcript (final + interim) for display
    var fullTranscriptForDisplay: String {
        if finalTranscript.isEmpty {
            return interimFull
        } else if interimFull.isEmpty {
            return finalTranscript
        } else {
            let needsSpace = !(finalTranscript.last?.isWhitespace ?? false) && !(interimFull.first?.isWhitespace ?? true)
            return finalTranscript + (needsSpace ? " " : "") + interimFull
        }
    }

    var ghostTailForRender: String {
        guard !interimFull.isEmpty else { return "" }
        if !finalTranscript.isEmpty, interimFull.hasPrefix(finalTranscript) {
            let tail = String(interimFull.dropFirst(finalTranscript.count))
            return tail.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if finalTranscript.isEmpty {
            return interimFull
        } else if interimFull.count > finalTranscript.count {
            return interimFull
        }
        return ""
    }

    func needsSpaceBetweenCommittedAndGhost() -> Bool {
        let committed = finalTranscript
        let ghost = ghostTailForRender
        guard !committed.isEmpty, !ghost.isEmpty else { return false }
        let whitespace = committed.last?.isWhitespace ?? false
        let leadingPunct = [",", ".", ";", "!", "?"].contains(String(ghost.first ?? " "))
        return !whitespace && !leadingPunct
    }

    private func bumpTick() { changeTick &+= 1 }
}
