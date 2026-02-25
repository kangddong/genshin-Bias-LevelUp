import Foundation
import UserNotifications
import UIKit

actor UNUserNotificationScheduler: NotificationScheduling {
    private let center: UNUserNotificationCenter
    private let availabilityService = DomainAvailabilityService()
    private let contentBuilder = NotificationContentBuilder()
    private let identifierPrefix = "domain-reminder-"
    private let scheduleHorizonDays = 14

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
        let slots = normalizedTimeSlots(preference.timeSlots)
        await removePreviouslyScheduledRequests()

        guard !slots.isEmpty else { return }

        let serverCalendar = ServerCalendar.calendar
        var deviceCalendar = Calendar(identifier: .gregorian)
        deviceCalendar.timeZone = .autoupdatingCurrent
        let now = Date()

        for dayOffset in 0..<scheduleHorizonDays {
            guard let targetDay = deviceCalendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            let localStartOfDay = deviceCalendar.startOfDay(for: targetDay)

            for slot in slots {
                guard let scheduledDate = scheduledDate(on: localStartOfDay, hour: slot.hour, minute: slot.minute, calendar: deviceCalendar),
                      scheduledDate > now else { continue }

                let serverDay = ServerCalendar.weekday(for: scheduledDate)
                let serverStartOfDay = serverCalendar.startOfDay(for: scheduledDate)

                let todayCharacters = availabilityService.availableCharacters(
                    on: serverDay,
                    catalog: catalog,
                    selectedIDs: selection.selectedCharacterIDs
                )
                let todayWeapons = availabilityService.availableWeapons(
                    on: serverDay,
                    catalog: catalog,
                    selectedIDs: selection.selectedWeaponIDs
                )

                guard let tomorrowDate = serverCalendar.date(byAdding: .day, value: 1, to: serverStartOfDay) else { continue }
                let tomorrowDay = ServerCalendar.weekday(for: tomorrowDate)
                let tomorrowCharacterCount = availabilityService.availableCharacters(
                    on: tomorrowDay,
                    catalog: catalog,
                    selectedIDs: selection.selectedCharacterIDs
                ).count
                let tomorrowWeaponCount = availabilityService.availableWeapons(
                    on: tomorrowDay,
                    catalog: catalog,
                    selectedIDs: selection.selectedWeaponIDs
                ).count

                let hasAvailableItems = !todayCharacters.isEmpty || !todayWeapons.isEmpty || tomorrowCharacterCount > 0 || tomorrowWeaponCount > 0
                guard hasAvailableItems else { continue }

                let payload = contentBuilder.build(
                    day: serverDay,
                    todayCharacters: todayCharacters,
                    todayWeapons: todayWeapons,
                    tomorrowCharacterCount: tomorrowCharacterCount,
                    tomorrowWeaponCount: tomorrowWeaponCount,
                    favoriteCharacterID: selection.favoriteCharacterID,
                    favoriteWeaponID: selection.favoriteWeaponID
                )

                let requestIdentifier = requestIdentifier(for: scheduledDate, calendar: deviceCalendar)
                let request = makeRequest(
                    identifier: requestIdentifier,
                    payload: payload,
                    fireDate: scheduledDate,
                    imagePath: payload.imagePath,
                    calendar: deviceCalendar
                )
                try? await center.add(request)
            }
        }
    }

    private func makeRequest(
        identifier: String,
        payload: NotificationPayload,
        fireDate: Date,
        imagePath: String?,
        calendar: Calendar
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = payload.title
        content.body = payload.body
        content.sound = .default

        if let imagePath,
           let attachment = attachment(for: imagePath, requestIdentifier: identifier) {
            content.attachments = [attachment]
        }

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        components.timeZone = calendar.timeZone
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    private func removePreviouslyScheduledRequests() async {
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }

        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func normalizedTimeSlots(_ slots: [NotificationTimeSlot]) -> [NotificationTimeSlot] {
        let sorted = slots.sorted { lhs, rhs in
            if lhs.hour == rhs.hour {
                return lhs.minute < rhs.minute
            }
            return lhs.hour < rhs.hour
        }

        var seen = Set<String>()
        return sorted.filter { slot in
            let key = "\(slot.hour):\(slot.minute)"
            return seen.insert(key).inserted
        }
    }

    private func scheduledDate(on day: Date, hour: Int, minute: Int, calendar: Calendar) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = hour
        components.minute = minute
        components.second = 0
        components.timeZone = calendar.timeZone
        return calendar.date(from: components)
    }

    private func requestIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return String(format: "\(identifierPrefix)%04d%02d%02d-%02d%02d", year, month, day, hour, minute)
    }

    private func attachment(for imagePath: String, requestIdentifier: String) -> UNNotificationAttachment? {
        if let base = Bundle.main.resourceURL {
            let url = base.appendingPathComponent(imagePath)
            if FileManager.default.fileExists(atPath: url.path) {
                return try? UNNotificationAttachment(identifier: "\(requestIdentifier)-image", url: url)
            }
        }

        let assetName = assetName(from: imagePath)
        guard !assetName.isEmpty,
              let image = UIImage(named: assetName, in: .main, with: nil),
              let pngData = image.pngData() else {
            return nil
        }

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("\(requestIdentifier)-\(assetName).png")

        do {
            try? FileManager.default.removeItem(at: tempURL)
            try pngData.write(to: tempURL, options: .atomic)
            return try UNNotificationAttachment(identifier: "\(requestIdentifier)-image", url: tempURL)
        } catch {
            return nil
        }
    }

    private func assetName(from path: String) -> String {
        let withoutExtension = (path as NSString).deletingPathExtension
        if let tail = withoutExtension.split(separator: "/").last {
            return String(tail)
        }
        return withoutExtension
    }
}
