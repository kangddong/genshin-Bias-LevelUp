import Foundation

final class UserDefaultsSelectionStore: SelectionStore, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let key = "user_selection"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSelection() -> UserSelection {
        guard let data = userDefaults.data(forKey: key),
              let selection = try? JSONDecoder().decode(UserSelection.self, from: data) else {
            return .empty
        }
        return selection
    }

    func saveSelection(_ selection: UserSelection) {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        userDefaults.set(data, forKey: key)
    }
}
