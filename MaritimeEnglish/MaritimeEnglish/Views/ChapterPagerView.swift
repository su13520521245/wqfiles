import SwiftUI

struct ChapterPagerView: View {
    let chapter: Chapter

    @Environment(SpeechManager.self) private var speech
    @AppStorage(SettingsKey.chineseVariant) private var variantRaw = ChineseVariant.traditional.rawValue
    @AppStorage(SettingsKey.speechRate) private var speechRate = SettingsDefault.speechRate
    @AppStorage(SettingsKey.accent) private var accentRaw = EnglishAccent.us.rawValue
    @AppStorage private var lastPage: Int
    @State private var page: Int

    init(chapter: Chapter) {
        self.chapter = chapter
        let key = SettingsKey.lastPage(chapter.id)
        _lastPage = AppStorage(wrappedValue: 0, key)
        let saved = UserDefaults.standard.integer(forKey: key)
        _page = State(initialValue: min(max(saved, 0), max(chapter.pageCount - 1, 0)))
    }

    private var variant: ChineseVariant { ChineseVariant(rawValue: variantRaw) ?? .traditional }
    private var noteOffset: Int { chapter.hasNotes ? 1 : 0 }

    var body: some View {
        TabView(selection: $page) {
            if chapter.hasNotes {
                NotesPageView(chapter: chapter, variant: variant, speak: speak)
                    .tag(0)
            }
            ForEach(Array(chapter.phrases.enumerated()), id: \.offset) { index, phrase in
                PhraseCardView(
                    id: itemID(phrase: index),
                    phrase: phrase,
                    variant: variant,
                    isSpeaking: speech.isSpeaking(itemID(phrase: index)),
                    onTapEnglish: { speak(id: itemID(phrase: index), item: phrase) }
                )
                .tag(index + noteOffset)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) { progressBar }
        .navigationTitle(chapter.title(variant))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: page) { _, newValue in
            lastPage = newValue
            speech.stop()
        }
        .onDisappear { speech.stop() }
    }

    private var progressBar: some View {
        VStack(spacing: 6) {
            ProgressView(value: Double(page + 1), total: Double(max(chapter.pageCount, 1)))
                .tint(.accentColor)
            HStack {
                if chapter.hasNotes && page == 0 {
                    Text(variant.pick("註", "注"))
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
                Spacer()
                Text("\(page + 1) / \(chapter.pageCount)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(.bar)
    }

    private func itemID(phrase index: Int) -> String { "c\(chapter.id)-p\(index)" }

    private func speak(id: String, item: TextItem) {
        speech.toggle(id: id, text: item.spokenEnglish, rate: speechRate, language: accentRaw)
    }
}
