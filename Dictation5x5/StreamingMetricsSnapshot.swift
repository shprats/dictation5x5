import Foundation

struct StreamingMetricsSnapshot: Codable {
    let sessionID: String
    let startTime: Date?
    let endTime: Date?
    let bytesSent: Int
    let samplesCaptured: Int
    let sampleRate: Double
    let avgKbpsUp: Double
    let firstInterimAt: TimeInterval?
    let totalDurationSeconds: Double?
}

final class StreamingMetrics: ObservableObject {
    private(set) var sessionID: String = ""
    private(set) var startTime: Date?
    private(set) var endTime: Date?
    private(set) var bytesSent: Int = 0
    private(set) var samplesCaptured: Int = 0
    private(set) var sampleRate: Double = 16_000
    private(set) var firstInterimAt: TimeInterval?
    private let lock = NSLock()

    func reset(sessionID: String) {
        lock.lock(); defer { lock.unlock() }
        self.sessionID = sessionID
        startTime = nil
        endTime = nil
        bytesSent = 0
        samplesCaptured = 0
        firstInterimAt = nil
    }

    func markSessionStart() {
        lock.lock(); defer { lock.unlock() }
        startTime = Date()
    }

    func markSessionEnd() {
        lock.lock(); defer { lock.unlock() }
        endTime = Date()
    }

    func markFirstInterim() {
        lock.lock(); defer { lock.unlock() }
        if let st = startTime, firstInterimAt == nil {
            firstInterimAt = Date().timeIntervalSince(st)
        }
    }

    func addBytesSent(_ count: Int) {
        lock.lock(); defer { lock.unlock() }
        bytesSent += count
    }

    func addCapturedSamples(count: Int, sampleRate: Double) {
        lock.lock(); defer { lock.unlock() }
        self.sampleRate = sampleRate
        samplesCaptured += count
    }

    func snapshot() -> StreamingMetricsSnapshot {
        lock.lock(); defer { lock.unlock() }
        var avgKbps: Double = 0
        var totalDur: Double?
        if let st = startTime {
            let endRef = endTime ?? Date()
            let elapsed = endRef.timeIntervalSince(st)
            if elapsed > 0 {
                avgKbps = (Double(bytesSent) * 8.0 / 1000.0) / elapsed
                totalDur = elapsed
            }
        }
        return StreamingMetricsSnapshot(
            sessionID: sessionID,
            startTime: startTime,
            endTime: endTime,
            bytesSent: bytesSent,
            samplesCaptured: samplesCaptured,
            sampleRate: sampleRate,
            avgKbpsUp: avgKbps,
            firstInterimAt: firstInterimAt,
            totalDurationSeconds: totalDur
        )
    }
}
