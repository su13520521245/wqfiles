import Foundation

struct ContentFile: Decodable, Sendable {
    let version: Int?
    let source: String?
    let chapters: [Chapter]
}

struct TextItem: Decodable, Hashable, Sendable {
    let en: String
    let sc: String
    let tc: String

    func chinese(_ variant: ChineseVariant) -> String {
        variant == .simplified ? sc : tc
    }

    /// 朗讀用英文：把填空底線換成 "blank"
    var spokenEnglish: String {
        en.replacingOccurrences(of: #"_{2,}"#, with: " blank ", options: .regularExpression)
    }
}

struct Chapter: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let titleEn: String
    let titleSc: String
    let titleTc: String
    let notes: [TextItem]
    let phrases: [TextItem]

    enum CodingKeys: String, CodingKey {
        case id, notes, phrases
        case titleEn = "title_en"
        case titleSc = "title_sc"
        case titleTc = "title_tc"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        titleEn = try c.decode(String.self, forKey: .titleEn)
        titleSc = try c.decode(String.self, forKey: .titleSc)
        titleTc = try c.decode(String.self, forKey: .titleTc)
        notes = try c.decodeIfPresent([TextItem].self, forKey: .notes) ?? []
        phrases = try c.decodeIfPresent([TextItem].self, forKey: .phrases) ?? []
    }

    func title(_ variant: ChineseVariant) -> String {
        variant == .simplified ? titleSc : titleTc
    }

    var hasNotes: Bool { !notes.isEmpty }

    /// 翻頁總數（註解頁算一頁）
    var pageCount: Int { phrases.count + (hasNotes ? 1 : 0) }
}
