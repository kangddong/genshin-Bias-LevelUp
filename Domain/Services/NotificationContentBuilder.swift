import Foundation

struct NotificationPayload: Equatable, Sendable {
    let title: String
    let body: String
}

struct NotificationContentBuilder {
    func build(day: WeekdayType, characters: [Character], weapons: [Weapon]) -> NotificationPayload {
        let title = "원신 요일 비경 알림"
        let body = "오늘(\(day.shortName)) 가능: 캐릭터 \(characters.count)명, 무기 \(weapons.count)개"
        return NotificationPayload(title: title, body: body)
    }
}
