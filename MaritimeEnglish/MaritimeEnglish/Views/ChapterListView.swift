import SwiftUI

struct ChapterListView: View {
    @Environment(ContentStore.self) private var store
    @AppStorage(SettingsKey.chineseVariant) private var variantRaw = ChineseVariant.traditional.rawValue

    private var variant: ChineseVariant { ChineseVariant(rawValue: variantRaw) ?? .traditional }

    var body: some View {
        NavigationStack {
            Group {
                if let error = store.loadError {
                    ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
                } else {
                    List(store.chapters) { chapter in
                        NavigationLink(value: chapter) {
                            ChapterRow(chapter: chapter, variant: variant)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(variant.pick("三副航海英語", "三副航海英语"))
            .navigationDestination(for: Chapter.self) { chapter in
                ChapterPagerView(chapter: chapter)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(variant.pick("設定", "设置"))
                }
            }
        }
    }
}

private struct ChapterRow: View {
    let chapter: Chapter
    let variant: ChineseVariant

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.titleEn)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(chapter.title(variant))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Text(variant.pick("\(chapter.phrases.count) 句", "\(chapter.phrases.count) 句"))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary, in: Capsule())
        }
        .padding(.vertical, 4)
    }
}
