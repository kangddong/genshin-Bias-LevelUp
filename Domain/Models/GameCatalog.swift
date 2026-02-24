import Foundation

struct GameCatalog: Codable, Sendable {
    let characters: [Character]
    let weapons: [Weapon]
    let schedules: [DomainSchedule]

    static let empty = GameCatalog(characters: [], weapons: [], schedules: [])

    var schedulesByMaterial: [String: DomainSchedule] {
        Dictionary(uniqueKeysWithValues: schedules.map { ($0.materialId, $0) })
    }
}
