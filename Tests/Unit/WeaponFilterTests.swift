import XCTest
@testable import MyBiasLevelUp

final class WeaponFilterTests: XCTestCase {
    private let weapons: [Weapon] = [
        Weapon(id: "s", name: "Sword", rarity: 4, type: .sword, materialId: "m1"),
        Weapon(id: "c", name: "Claymore", rarity: 4, type: .claymore, materialId: "m2"),
        Weapon(id: "p", name: "Polearm", rarity: 4, type: .polearm, materialId: "m3"),
        Weapon(id: "t", name: "Catalyst", rarity: 4, type: .catalyst, materialId: "m4"),
        Weapon(id: "b", name: "Bow", rarity: 4, type: .bow, materialId: "m5")
    ]

    func testAllFilterReturnsEverything() {
        let filtered = weapons.filter { WeaponFilterMode.all.contains($0) }
        XCTAssertEqual(filtered.map(\.id), ["s", "c", "p", "t", "b"])
    }

    func testTypeFilterReturnsOnlyMatchingType() {
        let filtered = weapons.filter { WeaponFilterMode.polearm.contains($0) }
        XCTAssertEqual(filtered.map(\.id), ["p"])
    }
}
