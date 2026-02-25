import Foundation

struct UserSelection: Codable, Equatable, Sendable {
    var selectedCharacterIDs: Set<String>
    var selectedWeaponIDs: Set<String>
    var favoriteCharacterID: String?
    var favoriteWeaponID: String?

    init(
        selectedCharacterIDs: Set<String>,
        selectedWeaponIDs: Set<String>,
        favoriteCharacterID: String? = nil,
        favoriteWeaponID: String? = nil
    ) {
        self.selectedCharacterIDs = selectedCharacterIDs
        self.selectedWeaponIDs = selectedWeaponIDs
        self.favoriteCharacterID = favoriteCharacterID
        self.favoriteWeaponID = favoriteWeaponID
    }

    static let empty = UserSelection(
        selectedCharacterIDs: [],
        selectedWeaponIDs: [],
        favoriteCharacterID: nil,
        favoriteWeaponID: nil
    )
}
