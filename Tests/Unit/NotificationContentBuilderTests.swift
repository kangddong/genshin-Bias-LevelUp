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
            favoriteWeaponID: nil
        )

        XCTAssertEqual(payload.title, "원신 요일 비경 알림")
        XCTAssertEqual(payload.body, "오늘/내일(금) 오픈: 캐릭터 1/2명, 무기 1/3개")
        XCTAssertNil(payload.imagePath)
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
            favoriteWeaponID: nil
        )

        XCTAssertEqual(payload.title, "감우, 오늘 재료 파밍 가능!")
        XCTAssertEqual(payload.body, "오늘은 감우 육성시킬 수 있는 날이야!")
        XCTAssertEqual(payload.imagePath, "Images/characters/a.png")
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
            favoriteWeaponID: "w"
        )

        XCTAssertEqual(payload.title, "호마의 지팡이, 오늘 돌파 가능!")
        XCTAssertEqual(payload.body, "오늘은 호마의 지팡이 육성시킬 수 있는 날이야!")
        XCTAssertEqual(payload.imagePath, "Images/weapons/w.png")
    }
}
