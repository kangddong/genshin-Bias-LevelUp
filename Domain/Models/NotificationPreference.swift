import Foundation

struct NotificationPreference: Codable, Equatable, Sendable {
    var hour: Int
    var minute: Int
    var enabledWeekdays: Set<WeekdayType>
    var defaultFilter: CharacterFilter

    static let `default` = NotificationPreference(
        hour: 20,
        minute: 0,
        enabledWeekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
        defaultFilter: .default
    )
}
