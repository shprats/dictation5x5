//
//  AudioResampler.swift
//  Dictation5x5
//
//  Created by pratik on 9/14/25.
//


import Accelerate
import AVFoundation

/// Fallback / alternative resampler if you prefer manual control rather than AVAudioConverter.
/// Accepts mono Float32 samples and produces resampled Float32 array.
struct AudioResampler {

    enum ResamplerError: Error {
        case invalidRatio
        case vDSPError
    }

    static func resampleMonoFloat32(input: [Float],
                                    from inRate: Double,
                                    to outRate: Double) throws -> [Float] {
        guard inRate > 0, outRate > 0 else { throw ResamplerError.invalidRatio }
        if inRate == outRate { return input }

        let ratio = outRate / inRate
        let outputCount = Int(Double(input.count) * ratio)

        var output = [Float](repeating: 0, count: outputCount)

        // vDSP linear interpolation
        var f = input
        let stride = vDSP_Stride(1)
        vDSP_vgenp(f,
                   stride,
                   [Float](unsafeUninitializedCapacity: outputCount) { buffer, initCount in
                       for i in 0..<outputCount {
                           buffer[i] = Float(Double(i)/ratio)
                       }
                       initCount = outputCount
                   },
                   stride,
                   &output,
                   stride,
                   vDSP_Length(outputCount),
                   vDSP_Length(f.count))

        return output
    }

    /// Convert Float32 -> Int16 LE after resample
    static func floatToInt16PCM(_ floatData: [Float]) -> Data {
        var data = Data(capacity: floatData.count * 2)
        for sample in floatData {
            let clamped = max(-1.0, min(1.0, sample))
            var s = Int16(clamped * 32767).littleEndian
            withUnsafeBytes(of: &s) { data.append(contentsOf: $0) }
        }
        return data
    }
}