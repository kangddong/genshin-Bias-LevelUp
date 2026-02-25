import XCTest
@testable import MyBiasLevelUp

@MainActor
final class AppStoreTests: XCTestCase {
    func testLoadCatalogRequestsAuthorizationOnAppStartWhenStatusIsNotDetermined() async {
        let scheduler = MockNotificationScheduler(initialStatus: .notDetermined, statusAfterRequest: .authorized)
        let store = makeStore(notificationScheduler: scheduler)

        await store.loadCatalogIfNeeded()

        let requestCallCount = await scheduler.requestAuthorizationCallCount
        XCTAssertEqual(requestCallCount, 1)
        XCTAssertEqual(store.notificationStatus, .authorized)
    }

    func testToggleCharacterRoutesToSystemSettingsWhenPermissionDenied() async {
        let scheduler = MockNotificationScheduler(initialStatus: .denied, statusAfterRequest: .denied)
        let settingsRouter = MockSettingsRouter()
        let store = makeStore(notificationScheduler: scheduler, settingsRouter: settingsRouter)

        await store.loadCatalogIfNeeded()
        store.toggleCharacter("amber")

        XCTAssertFalse(store.selection.selectedCharacterIDs.contains("amber"))
        XCTAssertEqual(settingsRouter.openCallCount, 1)
    }

    private func makeStore(
        notificationScheduler: MockNotificationScheduler,
        settingsRouter: MockSettingsRouter = MockSettingsRouter()
    ) -> AppStore {
        AppStore(
            dataRepository: StubGameDataRepository(),
            selectionStore: InMemorySelectionStore(),
            preferenceStore: InMemoryPreferenceStore(),
            notificationScheduler: notificationScheduler,
            settingsRouter: settingsRouter
        )
    }
}

private struct StubGameDataRepository: GameDataRepository {
    func loadCatalog() async throws -> GameCatalog {
        GameCatalog(
            characters: [Character(id: "amber", image: "", imageAlternatives: nil, name: "앰버", element: .pyro, nation: .mondstadt, materialId: "mat")],
            weapons: [],
            schedules: [DomainSchedule(materialId: "mat", materialName: "재료", domainName: "비경", weekdays: [.monday], kind: .character)]
        )
    }
}

private final class InMemorySelectionStore: SelectionStore, @unchecked Sendable {
    private var selection: UserSelection = .empty

    func loadSelection() -> UserSelection {
        selection
    }

    func saveSelection(_ selection: UserSelection) {
        self.selection = selection
    }
}

private final class InMemoryPreferenceStore: PreferenceStore, @unchecked Sendable {
    private var preference: NotificationPreference = .default

    func loadPreference() -> NotificationPreference {
        preference
    }

    func savePreference(_ preference: NotificationPreference) {
        self.preference = preference
    }
}

private actor MockNotificationScheduler: NotificationScheduling {
    private(set) var requestAuthorizationCallCount = 0
    private(set) var rescheduleCallCount = 0
    private var currentStatus: NotificationAuthorizationStatus
    private let statusAfterRequest: NotificationAuthorizationStatus

    init(initialStatus: NotificationAuthorizationStatus, statusAfterRequest: NotificationAuthorizationStatus) {
        self.currentStatus = initialStatus
        self.statusAfterRequest = statusAfterRequest
    }

    func requestAuthorization() async -> Bool {
        requestAuthorizationCallCount += 1
        currentStatus = statusAfterRequest
        return currentStatus.isAuthorized
    }

    func authorizationStatus() async -> NotificationAuthorizationStatus {
        currentStatus
    }

    func rescheduleAll(catalog: GameCatalog, selection: UserSelection, preference: NotificationPreference) async {
        rescheduleCallCount += 1
    }
}

@MainActor
private final class MockSettingsRouter: SystemSettingsRouting {
    private(set) var openCallCount = 0

    func openAppSettings() {
        openCallCount += 1
    }
}
