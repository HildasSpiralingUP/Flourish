import AVFoundation

final class AudioManager {
    private var engine: AVAudioEngine?

    // MARK: - Public

    func playChime()  { playTones([(523, 0.0), (659, 0.15), (784, 0.30)], wave: .sine, duration: 0.5) }
    func playWater()  { playNoise(count: 6, baseHz: 450, spread: 300, noteDuration: 0.08, spacing: 0.07) }
    func playPlant()  {
        playTone(hz: 200, wave: .sine, at: 0.0, duration: 0.3)
        playTone(hz: 350, wave: .sine, at: 0.15, duration: 0.2)
        playTones([(523, 0.3), (659, 0.4), (784, 0.5), (1047, 0.6)], wave: .sine, duration: 0.5)
    }
    func playCoins()  { playTones([(800,0),(950,0.06),(1100,0.12),(1250,0.18),(1400,0.24)], wave: .triangle, duration: 0.15) }
    func playBreathe(inhale: Bool) { playTone(hz: inhale ? 300 : 200, wave: .sine, at: 0, duration: 0.4) }

    // MARK: - Private

    private func playTones(_ pairs: [(Double, Double)], wave: Waveform, duration: Double) {
        for (hz, lag) in pairs { playTone(hz: hz, wave: wave, at: lag, duration: duration) }
    }

    private func playNoise(count: Int, baseHz: Double, spread: Double, noteDuration: Double, spacing: Double) {
        for i in 0..<count {
            let hz = baseHz + Double.random(in: 0...spread)
            playTone(hz: hz, wave: .sine, at: Double(i) * spacing, duration: noteDuration)
        }
    }

    private func playTone(hz: Double, wave: Waveform, at delay: Double, duration: Double, volume: Float = 0.12) {
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + delay) {
            self.synthesize(hz: hz, wave: wave, duration: duration, volume: volume)
        }
    }

    private func synthesize(hz: Double, wave: Waveform, duration: Double, volume: Float) {
        let sampleRate: Double = 44_100
        let frames = Int(sampleRate * duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames)) else { return }

        buffer.frameLength = AVAudioFrameCount(frames)
        let channelData = buffer.floatChannelData![0]

        for i in 0..<frames {
            let t = Double(i) / sampleRate
            let rawSample: Double
            switch wave {
            case .sine:     rawSample = sin(2 * .pi * hz * t)
            case .triangle: rawSample = 2 * abs(2 * (hz * t - floor(hz * t + 0.5))) - 1
            }
            // Envelope: short attack, exponential decay
            let attack: Double = 0.05
            let envelope = t < attack ? t / attack : exp(-4 * (t - attack) / duration)
            channelData[i] = Float(rawSample * envelope * Double(volume))
        }

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? engine.start()
        player.scheduleBuffer(buffer, completionHandler: nil)
        player.play()

        // Keep engine alive for the duration
        DispatchQueue.global().asyncAfter(deadline: .now() + duration + 0.1) {
            engine.stop()
        }
    }

    private enum Waveform { case sine, triangle }
}
