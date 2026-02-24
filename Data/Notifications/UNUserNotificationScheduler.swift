import Foundation
import UserNotifications

actor UNUserNotificationScheduler: NotificationScheduling {
    private let center: UNUserNotificationCenter
    private let availabilityService = DomainAvailabilityService()
    private let contentBuilder = NotificationContentBuilder()

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> NotificationAuthorizationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        @unknown default:
            return .notDetermined
        }
    }

    func rescheduleAll(catalog: GameCatalog, selection: UserSelection, preference: NotificationPreference) async {
        let ids = WeekdayType.ordered.map { "domain-reminder-\($0.rawValue)" }
        center.removePendingNotificationRequests(withIdentifiers: ids)

        for day in WeekdayType.ordered where preference.enabledWeekdays.contains(day) {
            let characters = availabilityService.availableCharacters(on: day, catalog: catalog, selectedIDs: selection.selectedCharacterIDs)
            let weapons = availabilityService.availableWeapons(on: day, catalog: catalog, selectedIDs: selection.selectedWeaponIDs)

            guard !characters.isEmpty || !weapons.isEmpty else { continue }

            let payload = contentBuilder.build(day: day, characters: characters, weapons: weapons)
            let content = UNMutableNotificationContent()
            content.title = payload.title
            content.body = payload.body
            content.sound = .default

            var components = DateComponents()
            components.timeZone = ServerCalendar.serverTimeZone
            components.weekday = day.calendarWeekday
            components.hour = preference.hour
            components.minute = preference.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "domain-reminder-\(day.rawValue)", content: content, trigger: trigger)
            try? await center.add(request)
        }
    }
}
