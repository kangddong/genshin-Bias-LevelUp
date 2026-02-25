import XCTest
@testable import MyBiasLevelUp

final class NotificationContentBuilderTests: XCTestCase {
    func testBuildSummaryContent() {
        let builder = NotificationContentBuilder()
        let payload = builder.build(
            day: .friday,
            characters: [Character(id: "a", image: "", imageAlternatives: nil, name: "A", element: .anemo, nation: .mondstadt, materialId: "m")],
            weapons: [Weapon(id: "w", name: "W", rarity: 4, type: .bow, materialId: "m")]
        )

        XCTAssertEqual(payload.title, "원신 요일 비경 알림")
        XCTAssertEqual(payload.body, "오늘(금) 가능: 캐릭터 1명, 무기 1개")
    }
}
