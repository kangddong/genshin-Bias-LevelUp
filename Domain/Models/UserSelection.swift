import Foundation

struct UserSelection: Codable, Equatable, Sendable {
    var selectedCharacterIDs: Set<String>
    var selectedWeaponIDs: Set<String>

    static let empty = UserSelection(selectedCharacterIDs: [], selectedWeaponIDs: [])
}
