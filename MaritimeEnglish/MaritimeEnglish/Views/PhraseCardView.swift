import SwiftUI

/// 一般句子頁：上半部英文（點擊朗讀），下半部中文；內容過長時可上下捲動
struct PhraseCardView: View {
    let id: String
    let phrase: TextItem
    let variant: ChineseVariant
    let isSpeaking: Bool
    let onTapEnglish: () -> Void

    private var englishFont: Font {
        switch phrase.en.count {
        case ..<50: .largeTitle
        case ..<100: .title
        default: .title2
        }
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    // 上半部：英文
                    VStack {
                        Spacer(minLength: 24)
                        EnglishText(text: phrase.en, font: englishFont.weight(.semibold),
                                    isSpeaking: isSpeaking, variant: variant, action: onTapEnglish)
                        Spacer(minLength: 24)
                    }
                    .frame(minHeight: geo.size.height * 0.5)

                    Divider().padding(.horizontal, 8)

                    // 下半部：中文
                    VStack {
                        Spacer(minLength: 24)
                        Text(phrase.chinese(variant))
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                        Spacer(minLength: 24)
                    }
                    .frame(minHeight: geo.size.height * 0.5 - 1)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

/// 可點擊朗讀的英文；朗讀中變色
struct EnglishText: View {
    let text: String
    let font: Font
    let isSpeaking: Bool
    let variant: ChineseVariant
    var alignment: TextAlignment = .center
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(text)
                    .font(font)
                    .multilineTextAlignment(alignment)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(isSpeaking ? Color.accentColor : Color.primary)
                Image(systemName: isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                    .font(.body)
                    .foregroundStyle(isSpeaking ? Color.accentColor : Color.secondary)
                    .symbolEffect(.variableColor.iterative, isActive: isSpeaking)
            }
            .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSpeaking)
        .accessibilityHint(isSpeaking ? variant.pick("點兩下停止朗讀", "点两下停止朗读")
                                      : variant.pick("點兩下朗讀英文", "点两下朗读英文"))
    }
}

/// 章節註解頁（第一頁），樣式與句子頁區分
struct NotesPageView: View {
    let chapter: Chapter
    let variant: ChineseVariant
    let speak: (String, TextItem) -> Void

    @Environment(SpeechManager.self) private var speech

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                Label(variant.pick("註", "注"), systemImage: "note.text")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.orange, in: Capsule())

                ForEach(Array(chapter.notes.enumerated()), id: \.offset) { index, note in
                    let id = "c\(chapter.id)-n\(index)"
                    VStack(alignment: .leading, spacing: 14) {
                        EnglishText(text: note.en, font: .body.weight(.medium),
                                    isSpeaking: speech.isSpeaking(id), variant: variant,
                                    alignment: .leading) {
                            speak(id, note)
                        }
                        Divider()
                        Text(note.chinese(variant))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                    }
                    .padding(18)
                    .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.orange.opacity(0.35), lineWidth: 1)
                    )
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
