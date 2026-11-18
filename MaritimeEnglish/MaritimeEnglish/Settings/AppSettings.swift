import Foundation

enum ChineseVariant: String, CaseIterable, Identifiable, Sendable {
    case traditional = "tc"
    case simplified = "sc"

    var id: String { rawValue }
    var label: String { self == .traditional ? "繁體中文" : "简体中文" }
}

enum EnglishAccent: String, CaseIterable, Identifiable, Sendable {
    case us = "en-US"
    case gb = "en-GB"

    var id: String { rawValue }
    var label: String { self == .us ? "美式 (en-US)" : "英式 (en-GB)" }
}

enum SettingsKey {
    static let chineseVariant = "chineseVariant"
    static let speechRate = "speechRate"
    static let accent = "accent"
    static func lastPage(_ chapterID: Int) -> String { "lastPage_\(chapterID)" }
}

enum SettingsDefault {
    static let speechRate: Double = 0.45
}

extension ChineseVariant {
    /// 介面字串依所選中文切換
    func pick(_ tc: String, _ sc: String) -> String { self == .simplified ? sc : tc }
}
