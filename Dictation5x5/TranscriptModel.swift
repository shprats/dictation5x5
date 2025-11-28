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
    /// INTERIM messages from the server are cumulative (full hypothesis), so we should just replace.
    /// Must be called on main thread to ensure UI updates.
    func mergeInterimCandidate(_ newHypRaw: String) {
        assert(Thread.isMainThread, "mergeInterimCandidate must be called on main thread")
        let newHyp = newHypRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newHyp.isEmpty else { return }
        
        // INTERIM messages are cumulative (full hypothesis from server)
        // Simply replace the interim - don't append or try to detect "new sentences"
        // The server handles cumulative logic, we just display what it sends
        if interimFull != newHyp {
            interimFull = newHyp
            bumpTick()
        } else {
            // Even if text is the same, bump tick to force UI refresh after pauses
            bumpTick()
        }
    }

    /// When a final arrives, REPLACE the committed transcript and clear interim.
    /// FINAL messages from the server are ALWAYS cumulative (full transcript so far).
    /// We should trust the server's FINAL as the source of truth and replace, not append.
    func handleFinal(_ nextFullRaw: String) {
        let nextFull = nextFullRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        prevFinalTranscript = finalTranscript
        
        // CRITICAL: Before accepting a FINAL, commit the current interim if it's longer than the current final.
        // This preserves content that was in the interim before the FINAL arrived.
        // This is especially important for large paragraphs that are still being transcribed.
        if !interimFull.isEmpty && interimFull.count > finalTranscript.count {
            // Interim is longer than current final - commit it first
            finalTranscript = interimFull
            debugPrint("[TranscriptModel] Committing longer interim to final before accepting new FINAL (interim: \(interimFull.count), old final: \(prevFinalTranscript.count))")
        }
        
        // FINAL messages from the server are cumulative (full transcript so far).
        // The server's FINAL is the authoritative source of truth.
        let finalLower = finalTranscript.lowercased()
        let nextFullLower = nextFull.lowercased()
        
        // PRIORITY 1: If FINAL is longer than current final, trust it as cumulative
        // This handles cases where a new paragraph comes in and FINAL doesn't start with current final
        // but is still the cumulative transcript from the server
        if nextFull.count > finalTranscript.count {
            // FINAL is longer - it's the authoritative cumulative transcript
            // Even if it doesn't start with current final (new paragraph), trust it
            finalTranscript = nextFull
            debugPrint("[TranscriptModel] Using longer FINAL as cumulative transcript (current: \(finalTranscript.count), new: \(nextFull.count)) - trusting server")
            interimFull = ""
        }
        // PRIORITY 2: Check if FINAL is cumulative (starts with current final or contains it)
        else if finalTranscript.isEmpty {
            // No final yet - use FINAL
            finalTranscript = nextFull
            debugPrint("[TranscriptModel] Using FINAL as first transcript (len=\(nextFull.count))")
            interimFull = ""
        }
        else {
            let finalPrefix = finalLower.prefix(min(50, finalLower.count))
            
            if nextFullLower.hasPrefix(finalPrefix) || nextFullLower.contains(finalPrefix) {
                // FINAL is cumulative (starts with or contains current final) - use FINAL as authoritative
                finalTranscript = nextFull
                debugPrint("[TranscriptModel] Using FINAL as cumulative transcript (current: \(finalTranscript.count), new: \(nextFull.count))")
                interimFull = ""
            } else if finalLower.contains(nextFullLower) {
                // Current final already contains the FINAL - keep current final (FINAL is a subset)
                debugPrint("[TranscriptModel] Keeping current final as it already contains FINAL (current: \(finalTranscript.count), FINAL: \(nextFull.count))")
                interimFull = ""
            } else if nextFull.count < finalTranscript.count {
                // FINAL is shorter than current final - might be incomplete
                // Only keep current final if it's significantly longer (more than 50% longer)
                // Otherwise, trust the FINAL (it might be a correction)
                if Double(finalTranscript.count) > Double(nextFull.count) * 1.5 && nextFull.count > 0 {
                    // Current final is much longer - keep it (FINAL might be incomplete)
                    debugPrint("[TranscriptModel] Keeping much longer final (current: \(finalTranscript.count), new: \(nextFull.count))")
                    // Preserve interim if it's longer than FINAL
                    if !interimFull.isEmpty && interimFull.count > nextFull.count {
                        debugPrint("[TranscriptModel] Preserving interim (len=\(interimFull.count)) as it's longer than FINAL")
                    } else {
                        interimFull = ""
                    }
                } else {
                    // Similar lengths or FINAL is reasonable - trust the FINAL (it's the server's authoritative version)
                    finalTranscript = nextFull
                    debugPrint("[TranscriptModel] Using FINAL despite being shorter (current: \(finalTranscript.count), new: \(nextFull.count)) - trusting server")
                    interimFull = ""
                }
            } else {
                // FINAL is equal length - trust it as cumulative (server is authoritative)
                finalTranscript = nextFull
                debugPrint("[TranscriptModel] Using equal-length FINAL as cumulative transcript (current: \(finalTranscript.count), new: \(nextFull.count))")
                interimFull = ""
            }
        }
        
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

    /// Call this on error or stop to preserve the last interim as the transcript (if no final or interim is longer)
    /// Since INTERIM is cumulative, we should prefer the longer one or the one that contains the other.
    func commitInterimIfNoFinal() {
        if !interimFull.isEmpty {
            // INTERIM is cumulative, so prefer the longer transcript
            // If interim is longer, it likely has more complete content
            if interimFull.count > finalTranscript.count {
                finalTranscript = interimFull
                debugPrint("[TranscriptModel] Committed interim (len=\(interimFull.count)) as it's longer than final (len=\(finalTranscript.count))")
            } else if finalTranscript.isEmpty {
                // No final at all - use interim
                finalTranscript = interimFull
                debugPrint("[TranscriptModel] Committed interim (len=\(interimFull.count)) as no final exists")
            } else {
                // Final exists and is longer or equal - keep final (it's the authoritative version)
                // Don't append - that would cause duplication since INTERIM is cumulative
                debugPrint("[TranscriptModel] Keeping final (len=\(finalTranscript.count)) over interim (len=\(interimFull.count))")
            }
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
            // This is common after pauses when the server sends a new interim that doesn't
            // directly continue from the final. We need to show the new interim text.
            
            // First, try to find if interim is a continuation with a different prefix
            // (e.g., final ends with "hello" and interim is "hello world" but server sent "hello world" as new interim)
            let commonPrefix = findCommonPrefix(finalTranscript, interimFull)
            
            if commonPrefix.count > 0 && commonPrefix.count >= finalTranscript.count / 2 {
                // There's substantial overlap - show the tail after common prefix
                let tail = String(interimFull.dropFirst(commonPrefix.count))
                let trimmedTail = tail.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedTail.isEmpty {
                    return trimmedTail
                }
            }
            
            // If no substantial overlap or tail is empty, check if interim is longer
            // This handles cases where interim is a continuation after a pause
            if interimFull.count > finalTranscript.count {
                // Interim is longer - likely a continuation, show the difference
                // Try to find where interim diverges from final
                let divergencePoint = findDivergencePoint(finalTranscript, interimFull)
                if divergencePoint > 0 {
                    let tail = String(interimFull.dropFirst(divergencePoint))
                    return tail.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                // If we can't find divergence, show full interim as it's new content
                return interimFull
            } else {
                // Interim is shorter or same length - likely a correction or partial update
                // Show the full interim to indicate new content
                return interimFull
            }
        }
    }
    
    /// Find the point where two strings diverge (where they stop matching)
    private func findDivergencePoint(_ str1: String, _ str2: String) -> Int {
        let minLength = min(str1.count, str2.count)
        for i in 0..<minLength {
            let idx1 = str1.index(str1.startIndex, offsetBy: i)
            let idx2 = str2.index(str2.startIndex, offsetBy: i)
            if str1[idx1] != str2[idx2] {
                return i
            }
        }
        // If we get here, one string is a prefix of the other
        return minLength
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
