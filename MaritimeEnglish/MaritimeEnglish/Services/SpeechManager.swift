import AVFoundation
import Observation

/// 包裝 AVSpeechSynthesizer（離線系統語音）
@MainActor
@Observable
final class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {
    /// 正在朗讀的項目 ID（用來把英文變色）
    private(set) var speakingID: String?

    @ObservationIgnored private let synthesizer = AVSpeechSynthesizer()
    @ObservationIgnored private var currentUtterance: ObjectIdentifier?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func isSpeaking(_ id: String) -> Bool { speakingID == id }

    /// 點一下朗讀；同一句正在朗讀時再點一下則停止
    func toggle(id: String, text: String, rate: Double, language: String) {
        if speakingID == id {
            stop()
            return
        }
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = Float(min(max(rate, 0.3), 0.6))
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.preUtteranceDelay = 0.05
        currentUtterance = ObjectIdentifier(utterance)
        speakingID = id
        synthesizer.speak(utterance)
    }

    func stop() {
        currentUtterance = nil
        speakingID = nil
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func finished(_ utteranceID: ObjectIdentifier) {
        guard utteranceID == currentUtterance else { return }
        currentUtterance = nil
        speakingID = nil
    }

    // MARK: AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in self.finished(id) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in self.finished(id) }
    }
}
