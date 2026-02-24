import XCTest
@testable import MyBiasLevelUp

final class CharacterFilterTests: XCTestCase {
    private let characters: [Character] = [
        Character(id: "a", image: "", imageAlternatives: nil, name: "A", element: .anemo, nation: .mondstadt, materialId: "m1"),
        Character(id: "b", image: "", imageAlternatives: nil, name: "B", element: .pyro, nation: .liyue, materialId: "m2")
    ]

    func testAllFilterReturnsEverything() {
        let filter = CharacterFilter(mode: .all, element: nil, nation: nil)
        XCTAssertEqual(filter.apply(to: characters).count, 2)
    }

    func testElementFilter() {
        let filter = CharacterFilter(mode: .element, element: .pyro, nation: nil)
        XCTAssertEqual(filter.apply(to: characters).map(\.id), ["b"])
    }

    func testRegionFilter() {
        let filter = CharacterFilter(mode: .region, element: nil, nation: .mondstadt)
        XCTAssertEqual(filter.apply(to: characters).map(\.id), ["a"])
    }
}
