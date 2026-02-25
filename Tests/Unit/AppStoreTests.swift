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

    func testUpdateNotificationTimeReschedulesWhenAuthorized() async throws {
        let scheduler = MockNotificationScheduler(initialStatus: .authorized, statusAfterRequest: .authorized)
        let store = makeStore(notificationScheduler: scheduler)

        await store.loadCatalogIfNeeded()
        let initialCallCount = await scheduler.rescheduleCallCount
        let targetSlot = try XCTUnwrap(store.notificationTimeSlots.first)
        var components = DateComponents()
        components.hour = 19
        components.minute = 22
        let updatedDate = try XCTUnwrap(Calendar.current.date(from: components))

        store.updateNotificationTime(slotID: targetSlot.id, date: updatedDate)
        await waitForRescheduleCallCount(scheduler, atLeast: initialCallCount + 1)

        XCTAssertEqual(store.notificationTimeSlots.first?.hour, 19)
        XCTAssertEqual(store.notificationTimeSlots.first?.minute, 22)
    }

    func testAddNotificationTimeSlotReschedulesWhenAuthorized() async {
        let scheduler = MockNotificationScheduler(initialStatus: .authorized, statusAfterRequest: .authorized)
        let store = makeStore(notificationScheduler: scheduler)

        await store.loadCatalogIfNeeded()
        let initialCallCount = await scheduler.rescheduleCallCount

        store.addNotificationTimeSlot()
        await waitForRescheduleCallCount(scheduler, atLeast: initialCallCount + 1)

        XCTAssertEqual(store.notificationTimeSlots.count, 2)
    }

    func testRemoveNotificationTimeSlotReschedulesWhenAuthorized() async {
        let scheduler = MockNotificationScheduler(initialStatus: .authorized, statusAfterRequest: .authorized)
        let preferenceStore = InMemoryPreferenceStore(
            preference: NotificationPreference(
                timeSlots: [
                    NotificationTimeSlot(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, hour: 8, minute: 0),
                    NotificationTimeSlot(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, hour: 12, minute: 0)
                ],
                defaultFilter: .default
            )
        )
        let store = makeStore(notificationScheduler: scheduler, preferenceStore: preferenceStore)

        await store.loadCatalogIfNeeded()
        let initialCallCount = await scheduler.rescheduleCallCount
        let removedID = store.notificationTimeSlots[1].id

        store.removeNotificationTimeSlot(removedID)
        await waitForRescheduleCallCount(scheduler, atLeast: initialCallCount + 1)

        XCTAssertEqual(store.notificationTimeSlots.count, 1)
        XCTAssertFalse(store.notificationTimeSlots.contains(where: { $0.id == removedID }))
    }

    private func makeStore(
        notificationScheduler: MockNotificationScheduler,
        settingsRouter: MockSettingsRouter = MockSettingsRouter(),
        preferenceStore: InMemoryPreferenceStore = InMemoryPreferenceStore()
    ) -> AppStore {
        AppStore(
            dataRepository: StubGameDataRepository(),
            selectionStore: InMemorySelectionStore(),
            preferenceStore: preferenceStore,
            notificationScheduler: notificationScheduler,
            settingsRouter: settingsRouter
        )
    }

    private func waitForRescheduleCallCount(
        _ scheduler: MockNotificationScheduler,
        atLeast expected: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<40 {
            let value = await scheduler.rescheduleCallCount
            if value >= expected { return }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        let finalCount = await scheduler.rescheduleCallCount
        XCTFail("Expected reschedule count >= \(expected), got \(finalCount)", file: file, line: line)
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
    private var preference: NotificationPreference

    init(preference: NotificationPreference = .default) {
        self.preference = preference
    }

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
