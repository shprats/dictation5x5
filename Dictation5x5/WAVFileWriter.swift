import Foundation

struct WAVFileWriter {
    static func wrapPCMAsWAV(pcmData: Data,
                             sampleRate: Int,
                             channels: Int,
                             bitsPerSample: Int) -> Data {
        let byteRate = sampleRate * channels * bitsPerSample / 8
        let blockAlign = channels * bitsPerSample / 8
        let subchunk2Size = pcmData.count
        let chunkSize = 36 + subchunk2Size

        var data = Data()
        data.append("RIFF".data(using: .ascii)!)
        data.append(UInt32(chunkSize).littleEndianData)
        data.append("WAVE".data(using: .ascii)!)
        data.append("fmt ".data(using: .ascii)!)
        data.append(UInt32(16).littleEndianData)
        data.append(UInt16(1).littleEndianData)
        data.append(UInt16(channels).littleEndianData)
        data.append(UInt32(sampleRate).littleEndianData)
        data.append(UInt32(byteRate).littleEndianData)
        data.append(UInt16(blockAlign).littleEndianData)
        data.append(UInt16(bitsPerSample).littleEndianData)
        data.append("data".data(using: .ascii)!)
        data.append(UInt32(subchunk2Size).littleEndianData)
        data.append(pcmData)
        return data
    }
}

private extension UInt16 {
    var littleEndianData: Data {
        var le = self.littleEndian
        return Data(bytes: &le, count: MemoryLayout<UInt16>.size)
    }
}

private extension UInt32 {
    var littleEndianData: Data {
        var le = self.littleEndian
        return Data(bytes: &le, count: MemoryLayout<UInt32>.size)
    }
}
