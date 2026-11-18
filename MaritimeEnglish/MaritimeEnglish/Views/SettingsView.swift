import SwiftUI

struct SettingsView: View {
    @Environment(SpeechManager.self) private var speech
    @AppStorage(SettingsKey.chineseVariant) private var variantRaw = ChineseVariant.traditional.rawValue
    @AppStorage(SettingsKey.speechRate) private var speechRate = SettingsDefault.speechRate
    @AppStorage(SettingsKey.accent) private var accentRaw = EnglishAccent.us.rawValue

    private var variant: ChineseVariant { ChineseVariant(rawValue: variantRaw) ?? .traditional }

    var body: some View {
        Form {
            Section(variant.pick("中文顯示", "中文显示")) {
                Picker(variant.pick("中文顯示", "中文显示"), selection: $variantRaw) {
                    ForEach(ChineseVariant.allCases) { v in
                        Text(v.label).tag(v.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text(variant.pick("語速", "语速"))
                        Spacer()
                        Text(speechRate, format: .number.precision(.fractionLength(2)))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $speechRate, in: 0.3...0.6, step: 0.01) {
                        Text(variant.pick("語速", "语速"))
                    } minimumValueLabel: {
                        Image(systemName: "tortoise")
                    } maximumValueLabel: {
                        Image(systemName: "hare")
                    }
                }

                Picker(variant.pick("口音", "口音"), selection: $accentRaw) {
                    ForEach(EnglishAccent.allCases) { a in
                        Text(a.label).tag(a.rawValue)
                    }
                }

                Button {
                    speech.toggle(id: "settings-preview",
                                  text: "Singapore VTS, this is motor tanker FPMC C Lord, over.",
                                  rate: speechRate, language: accentRaw)
                } label: {
                    Label(speech.isSpeaking("settings-preview") ? variant.pick("停止", "停止") : variant.pick("試聽", "试听"),
                          systemImage: speech.isSpeaking("settings-preview") ? "stop.fill" : "speaker.wave.2.fill")
                }
            } header: {
                Text(variant.pick("英文朗讀", "英文朗读"))
            } footer: {
                Text(variant.pick("使用 iPhone 內建語音，離線可用。可在「設定 › 輔助使用 › 朗讀內容 › 聲音」下載更高品質的英文語音。",
                                  "使用 iPhone 内置语音，离线可用。可在「设置 › 辅助功能 › 朗读内容 › 声音」下载更高质量的英文语音。"))
            }
        }
        .navigationTitle(variant.pick("設定", "设置"))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { speech.stop() }
    }
}
