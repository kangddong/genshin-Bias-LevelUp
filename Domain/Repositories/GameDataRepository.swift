import Foundation

protocol GameDataRepository: Sendable {
    func loadCatalog() async throws -> GameCatalog
}

protocol SelectionStore: Sendable {
    func loadSelection() -> UserSelection
    func saveSelection(_ selection: UserSelection)
}

protocol PreferenceStore: Sendable {
    func loadPreference() -> NotificationPreference
    func savePreference(_ preference: NotificationPreference)
}
