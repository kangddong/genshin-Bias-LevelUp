import Foundation

struct NotificationPayload: Equatable, Sendable {
    let title: String
    let body: String
    let imagePath: String?
}

struct NotificationContentBuilder {
    func build(
        day: WeekdayType,
        todayCharacters: [Character],
        todayWeapons: [Weapon],
        tomorrowCharacterCount: Int,
        tomorrowWeaponCount: Int,
        favoriteCharacterID: String?,
        favoriteWeaponID: String?
    ) -> NotificationPayload {
        if let favoriteCharacterID,
           let favoriteCharacter = todayCharacters.first(where: { $0.id == favoriteCharacterID }) {
            return NotificationPayload(
                title: "\(favoriteCharacter.name), 오늘 재료 파밍 가능!",
                body: "오늘은 \(favoriteCharacter.name) 육성시킬 수 있는 날이야!",
                imagePath: favoriteCharacter.localImage
            )
        }

        if let favoriteWeaponID,
           let favoriteWeapon = todayWeapons.first(where: { $0.id == favoriteWeaponID }) {
            return NotificationPayload(
                title: "\(favoriteWeapon.name), 오늘 돌파 가능!",
                body: "오늘은 \(favoriteWeapon.name) 육성시킬 수 있는 날이야!",
                imagePath: favoriteWeapon.localImage
            )
        }

        let title = "원신 요일 비경 알림"
        let body = "오늘/내일(\(day.shortName)) 오픈: 캐릭터 \(todayCharacters.count)/\(tomorrowCharacterCount)명, 무기 \(todayWeapons.count)/\(tomorrowWeaponCount)개"
        return NotificationPayload(title: title, body: body, imagePath: nil)
    }
}
