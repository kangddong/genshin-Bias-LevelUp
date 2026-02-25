import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var catalog: GameCatalog = .empty
    @Published var selection: UserSelection
    @Published var preference: NotificationPreference
    @Published var characterFilter: CharacterFilter
    @Published var weaponFilter: WeaponFilterMode = .all
    @Published var notificationStatus: NotificationAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    let availabilityService = DomainAvailabilityService()

    private let dataRepository: GameDataRepository
    private let selectionStore: SelectionStore
    private let preferenceStore: PreferenceStore
    private let notificationScheduler: NotificationScheduling

    private var didLoad = false

    init(
        dataRepository: GameDataRepository,
        selectionStore: SelectionStore,
        preferenceStore: PreferenceStore,
        notificationScheduler: NotificationScheduling
    ) {
        self.dataRepository = dataRepository
        self.selectionStore = selectionStore
        self.preferenceStore = preferenceStore
        self.notificationScheduler = notificationScheduler

        let initialSelection = selectionStore.loadSelection()
        let initialPreference = preferenceStore.loadPreference()
        self.selection = initialSelection
        self.preference = initialPreference
        self.characterFilter = initialPreference.defaultFilter
    }

    static func makeDefault() -> AppStore {
        AppStore(
            dataRepository: BundleGameDataRepository(),
            selectionStore: UserDefaultsSelectionStore(),
            preferenceStore: UserDefaultsPreferenceStore(),
            notificationScheduler: UNUserNotificationScheduler()
        )
    }

    func loadCatalogIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true

        do {
            catalog = try await dataRepository.loadCatalog()
            notificationStatus = await notificationScheduler.authorizationStatus()
            await rescheduleIfPossible()
        } catch {
            errorMessage = "데이터를 불러오지 못했습니다: \(error.localizedDescription)"
        }
    }

    func toggleCharacter(_ id: String) {
        if selection.selectedCharacterIDs.contains(id) {
            selection.selectedCharacterIDs.remove(id)
        } else {
            selection.selectedCharacterIDs.insert(id)
        }
        selectionStore.saveSelection(selection)
        Task { await rescheduleIfPossible() }
    }

    func toggleWeapon(_ id: String) {
        if selection.selectedWeaponIDs.contains(id) {
            selection.selectedWeaponIDs.remove(id)
        } else {
            selection.selectedWeaponIDs.insert(id)
        }
        selectionStore.saveSelection(selection)
        Task { await rescheduleIfPossible() }
    }

    func updateCharacterFilter(_ filter: CharacterFilter) {
        characterFilter = filter
        preference.defaultFilter = filter
        preferenceStore.savePreference(preference)
    }

    func updateWeaponFilter(_ filter: WeaponFilterMode) {
        weaponFilter = filter
    }

    func updateNotificationTime(date: Date) {
        let calendar = Calendar.current
        preference.hour = calendar.component(.hour, from: date)
        preference.minute = calendar.component(.minute, from: date)
        preferenceStore.savePreference(preference)
        Task { await rescheduleIfPossible() }
    }

    func toggleNotificationWeekday(_ day: WeekdayType) {
        if preference.enabledWeekdays.contains(day) {
            preference.enabledWeekdays.remove(day)
        } else {
            preference.enabledWeekdays.insert(day)
        }
        preferenceStore.savePreference(preference)
        Task { await rescheduleIfPossible() }
    }

    func requestNotificationAuthorization() async {
        _ = await notificationScheduler.requestAuthorization()
        notificationStatus = await notificationScheduler.authorizationStatus()
        await rescheduleIfPossible()
    }

    var filteredCharacters: [Character] {
        characterFilter.apply(to: catalog.characters)
    }

    var filteredWeapons: [Weapon] {
        catalog.weapons.filter { weaponFilter.contains($0) }
    }

    func timeAsDate() -> Date {
        var components = DateComponents()
        components.hour = preference.hour
        components.minute = preference.minute
        return Calendar.current.date(from: components) ?? Date()
    }

    private func rescheduleIfPossible() async {
        guard notificationStatus.isAuthorized else { return }
        await notificationScheduler.rescheduleAll(catalog: catalog, selection: selection, preference: preference)
    }
}
