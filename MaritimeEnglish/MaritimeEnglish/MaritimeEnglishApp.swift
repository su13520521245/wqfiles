import SwiftUI
import AVFoundation

@main
struct MaritimeEnglishApp: App {
    @State private var store = ContentStore()
    @State private var speech = SpeechManager()

    init() {
        // 靜音鍵開啟時仍可發音
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            ChapterListView()
                .environment(store)
                .environment(speech)
        }
    }
}
