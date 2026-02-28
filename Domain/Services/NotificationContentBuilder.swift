import Foundation

struct NotificationPayload: Equatable, Sendable {
    let title: String
    let body: String
    let imagePath: String?
}

struct NotificationContentBuilder {
    private let inactiveDayThreshold = 3

    func build(
        day: WeekdayType,
        todayCharacters: [Character],
        todayWeapons: [Weapon],
        tomorrowCharacterCount: Int,
        tomorrowWeaponCount: Int,
        favoriteCharacterID: String?,
        favoriteWeaponID: String?,
        selectedCharacterCount: Int,
        selectedWeaponCount: Int,
        inactiveDays: Int,
        isFirstSlotOfDay: Bool
    ) -> NotificationPayload? {
        if let favoriteCharacterID,
           let favoriteCharacter = todayCharacters.first(where: { $0.id == favoriteCharacterID }) {
            return NotificationPayload(
                title: "\(favoriteCharacter.name), 오늘 육성 찬스",
                body: "\(day.shortName)요일 비경이 열렸어요. \(favoriteCharacter.name) 특성 재료를 모을 수 있어요.",
                imagePath: favoriteCharacter.localImage
            )
        }

        if let favoriteWeaponID,
           let favoriteWeapon = todayWeapons.first(where: { $0.id == favoriteWeaponID }) {
            return NotificationPayload(
                title: "\(favoriteWeapon.name), 오늘 돌파 찬스",
                body: "\(day.shortName)요일 비경이 열렸어요. \(favoriteWeapon.name) 돌파 재료를 모을 수 있어요.",
                imagePath: favoriteWeapon.localImage
            )
        }

        if inactiveDays >= inactiveDayThreshold {
            guard isFirstSlotOfDay else { return nil }
            guard (selectedCharacterCount + selectedWeaponCount) > 0 else { return nil }

            let todayTotal = todayCharacters.count + todayWeapons.count
            let tomorrowTotal = tomorrowCharacterCount + tomorrowWeaponCount
            return NotificationPayload(
                title: "잠깐! 오늘 비경 확인할 시간",
                body: "\(inactiveDays)일째 앱 미접속 중이에요. 오늘/내일 오픈 \(todayTotal)/\(tomorrowTotal)개를 확인해보세요.",
                imagePath: "paimon"
            )
        }

        let hasAvailableItems = !todayCharacters.isEmpty || !todayWeapons.isEmpty || tomorrowCharacterCount > 0 || tomorrowWeaponCount > 0
        guard hasAvailableItems else { return nil }

        let title = "\(day.shortName)요일 비경 알림"
        let body = "오늘 캐릭터 \(todayCharacters.count)명·무기 \(todayWeapons.count)개 / 내일 캐릭터 \(tomorrowCharacterCount)명·무기 \(tomorrowWeaponCount)개"
        let imagePath = todayCharacters.first?.localImage ?? todayWeapons.first?.localImage
        return NotificationPayload(title: title, body: body, imagePath: imagePath)
    }
}
