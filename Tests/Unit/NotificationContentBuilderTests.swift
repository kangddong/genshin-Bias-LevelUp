import XCTest
@testable import MyBiasLevelUp

final class NotificationContentBuilderTests: XCTestCase {
    func testBuildSummaryContentWhenNoFavoriteAvailable() {
        let builder = NotificationContentBuilder()
        let payload = builder.build(
            day: .friday,
            todayCharacters: [Character(id: "a", image: "", imageAlternatives: nil, name: "A", element: .anemo, nation: .mondstadt, materialId: "m")],
            todayWeapons: [Weapon(id: "w", name: "W", rarity: 4, type: .bow, materialId: "m")],
            tomorrowCharacterCount: 2,
            tomorrowWeaponCount: 3,
            favoriteCharacterID: nil,
            favoriteWeaponID: nil,
            selectedCharacterCount: 1,
            selectedWeaponCount: 1,
            inactiveDays: 0,
            isFirstSlotOfDay: true
        )

        XCTAssertEqual(payload?.title, "금요일 비경 알림")
        XCTAssertEqual(payload?.body, "오늘 캐릭터 1명·무기 1개 / 내일 캐릭터 2명·무기 3개")
        XCTAssertNil(payload?.imagePath)
    }

    func testBuildFavoriteCharacterContent() {
        let builder = NotificationContentBuilder()
        let payload = builder.build(
            day: .monday,
            todayCharacters: [Character(id: "a", image: "", imageAlternatives: nil, localImage: "Images/characters/a.png", name: "감우", element: .cryo, nation: .liyue, materialId: "m")],
            todayWeapons: [],
            tomorrowCharacterCount: 0,
            tomorrowWeaponCount: 0,
            favoriteCharacterID: "a",
            favoriteWeaponID: nil,
            selectedCharacterCount: 1,
            selectedWeaponCount: 0,
            inactiveDays: 0,
            isFirstSlotOfDay: true
        )

        XCTAssertEqual(payload?.title, "감우, 오늘 육성 찬스")
        XCTAssertEqual(payload?.body, "월요일 비경이 열렸어요. 감우 특성 재료를 모을 수 있어요.")
        XCTAssertEqual(payload?.imagePath, "Images/characters/a.png")
    }

    func testBuildFavoriteWeaponContentWhenCharacterIsUnavailable() {
        let builder = NotificationContentBuilder()
        let payload = builder.build(
            day: .tuesday,
            todayCharacters: [],
            todayWeapons: [Weapon(id: "w", name: "호마의 지팡이", rarity: 5, image: "", imageAlternatives: nil, localImage: "Images/weapons/w.png", type: .polearm, materialId: "m")],
            tomorrowCharacterCount: 0,
            tomorrowWeaponCount: 1,
            favoriteCharacterID: "a",
            favoriteWeaponID: "w",
            selectedCharacterCount: 0,
            selectedWeaponCount: 1,
            inactiveDays: 0,
            isFirstSlotOfDay: true
        )

        XCTAssertEqual(payload?.title, "호마의 지팡이, 오늘 돌파 찬스")
        XCTAssertEqual(payload?.body, "화요일 비경이 열렸어요. 호마의 지팡이 돌파 재료를 모을 수 있어요.")
        XCTAssertEqual(payload?.imagePath, "Images/weapons/w.png")
    }

    func testBuildEngagementContentWhenInactiveForThreeDays() {
        let builder = NotificationContentBuilder()
        let payload = builder.build(
            day: .saturday,
            todayCharacters: [Character(id: "a", image: "", imageAlternatives: nil, name: "A", element: .anemo, nation: .mondstadt, materialId: "m")],
            todayWeapons: [],
            tomorrowCharacterCount: 2,
            tomorrowWeaponCount: 1,
            favoriteCharacterID: nil,
            favoriteWeaponID: nil,
            selectedCharacterCount: 2,
            selectedWeaponCount: 1,
            inactiveDays: 3,
            isFirstSlotOfDay: true
        )

        XCTAssertEqual(payload?.title, "잠깐! 오늘 비경 확인할 시간")
        XCTAssertEqual(payload?.body, "3일째 앱 미접속 중이에요. 오늘/내일 오픈 1/3개를 확인해보세요.")
        XCTAssertEqual(payload?.imagePath, "paimon")
    }

    func testBuildReturnsNilWhenNoAvailableItemsAndInactiveConditionNotMet() {
        let builder = NotificationContentBuilder()
        let payload = builder.build(
            day: .wednesday,
            todayCharacters: [],
            todayWeapons: [],
            tomorrowCharacterCount: 0,
            tomorrowWeaponCount: 0,
            favoriteCharacterID: nil,
            favoriteWeaponID: nil,
            selectedCharacterCount: 1,
            selectedWeaponCount: 0,
            inactiveDays: 2,
            isFirstSlotOfDay: true
        )

        XCTAssertNil(payload)
    }
}
