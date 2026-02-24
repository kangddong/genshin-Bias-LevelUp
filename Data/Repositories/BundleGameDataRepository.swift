import Foundation

final class BundleGameDataRepository: GameDataRepository, @unchecked Sendable {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadCatalog() async throws -> GameCatalog {
        let characters: [Character] = try Self.decodeJSON(named: "characters", in: bundle)
        let weapons: [Weapon] = try Self.decodeJSON(named: "weapons", in: bundle)
        let schedules: [DomainSchedule] = try Self.decodeJSON(named: "schedules", in: bundle)
        return GameCatalog(characters: characters, weapons: weapons, schedules: schedules)
    }

    private static func decodeJSON<T: Decodable>(named name: String, in bundle: Bundle) throws -> T {
        let candidates: [URL?] = [
            bundle.url(forResource: name, withExtension: "json", subdirectory: "Data"),
            bundle.url(forResource: name, withExtension: "json")
        ]

        guard let url = candidates.compactMap({ $0 }).first else {
            throw NSError(domain: "BundleGameDataRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing resource: \(name).json"])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
