import Foundation

final class UserDefaultsPreferenceStore: PreferenceStore, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let key = "notification_preference"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadPreference() -> NotificationPreference {
        guard let data = userDefaults.data(forKey: key),
              let preference = try? JSONDecoder().decode(NotificationPreference.self, from: data) else {
            return .default
        }
        return preference
    }

    func savePreference(_ preference: NotificationPreference) {
        guard let data = try? JSONEncoder().encode(preference) else { return }
        userDefaults.set(data, forKey: key)
    }
}
