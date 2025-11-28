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
    /// Must be called on main thread to ensure UI updates.
    func mergeInterimCandidate(_ newHypRaw: String) {
        assert(Thread.isMainThread, "mergeInterimCandidate must be called on main thread")
        let newHyp = newHypRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newHyp.isEmpty else { return }
        // Only update if text actually changed to avoid unnecessary UI refreshes
        if interimFull != newHyp {
            interimFull = newHyp
            bumpTick()
        }
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
        if finalTranscript.isEmpty {
            // No final transcript yet - show all interim
            return interimFull
        } else if interimFull.hasPrefix(finalTranscript) {
            // Interim continues from final - show only the new tail
            let tail = String(interimFull.dropFirst(finalTranscript.count))
            return tail.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // Interim doesn't start with final (can happen after pause/correction)
            // Show the portion that's different - this handles cases where interim is a correction
            // or continuation after a pause where the server sends a different prefix
            if interimFull.count > finalTranscript.count {
                // Interim is longer - might be continuation with different prefix
                // Find common prefix and show the rest
                let commonPrefix = findCommonPrefix(finalTranscript, interimFull)
                if commonPrefix.count > 0 {
                    let tail = String(interimFull.dropFirst(commonPrefix.count))
                    return tail.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                // No common prefix - show full interim as it's likely a correction/continuation
                return interimFull
            } else {
                // Interim is shorter or same length - likely a correction, show it
                return interimFull
            }
        }
    }
    
    private func findCommonPrefix(_ str1: String, _ str2: String) -> String {
        let minLength = min(str1.count, str2.count)
        var commonLength = 0
        for i in 0..<minLength {
            if str1[str1.index(str1.startIndex, offsetBy: i)] == str2[str2.index(str2.startIndex, offsetBy: i)] {
                commonLength += 1
            } else {
                break
            }
        }
        return String(str1.prefix(commonLength))
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
