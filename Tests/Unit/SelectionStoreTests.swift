import XCTest
@testable import MyBiasLevelUp

final class SelectionStoreTests: XCTestCase {
    func testSaveAndLoadSelection() {
        let userDefaults = UserDefaults(suiteName: "SelectionStoreTests")!
        userDefaults.removePersistentDomain(forName: "SelectionStoreTests")

        let store = UserDefaultsSelectionStore(userDefaults: userDefaults)
        let saved = UserSelection(selectedCharacterIDs: ["amber"], selectedWeaponIDs: ["homa"])
        store.saveSelection(saved)

        let loaded = store.loadSelection()
        XCTAssertEqual(saved, loaded)
    }
}
