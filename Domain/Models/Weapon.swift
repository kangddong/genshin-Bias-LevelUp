import Foundation

struct Weapon: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let rarity: Int
    let materialId: String
}
