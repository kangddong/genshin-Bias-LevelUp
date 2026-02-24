import XCTest
@testable import MyBiasLevelUp

final class DomainAvailabilityServiceTests: XCTestCase {
    func testAvailableCharactersForSelectedDay() {
        let catalog = GameCatalog(
            characters: [
                Character(id: "a", image: "", imageAlternatives: nil, name: "A", element: .anemo, nation: .mondstadt, materialId: "matA"),
                Character(id: "b", image: "", imageAlternatives: nil, name: "B", element: .pyro, nation: .liyue, materialId: "matB")
            ],
            weapons: [],
            schedules: [
                DomainSchedule(materialId: "matA", materialName: "재료A", domainName: "d", weekdays: [.monday], kind: .character),
                DomainSchedule(materialId: "matB", materialName: "재료B", domainName: "d", weekdays: [.tuesday], kind: .character)
            ]
        )

        let service = DomainAvailabilityService()
        let result = service.availableCharacters(on: .monday, catalog: catalog)

        XCTAssertEqual(result.map(\.id), ["a"])
    }
}
