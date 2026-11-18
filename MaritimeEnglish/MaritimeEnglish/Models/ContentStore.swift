import Foundation
import Observation

@MainActor
@Observable
final class ContentStore {
    private(set) var chapters: [Chapter] = []
    private(set) var loadError: String?

    init() {
        guard let url = Bundle.main.url(forResource: "MaritimeEnglish_content", withExtension: "json") else {
            loadError = "找不到 MaritimeEnglish_content.json"
            return
        }
        do {
            let data = try Data(contentsOf: url)
            chapters = try JSONDecoder().decode(ContentFile.self, from: data).chapters
        } catch {
            loadError = "讀取內容失敗：\(error.localizedDescription)"
        }
    }
}
