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
    private let settingsRouter: SystemSettingsRouting

    private var didLoad = false

    private static let maxNotificationSlots = 3
    private static let minimumNotificationGapMinutes = 4 * 60

    init(
        dataRepository: GameDataRepository,
        selectionStore: SelectionStore,
        preferenceStore: PreferenceStore,
        notificationScheduler: NotificationScheduling,
        settingsRouter: SystemSettingsRouting
    ) {
        self.dataRepository = dataRepository
        self.selectionStore = selectionStore
        self.preferenceStore = preferenceStore
        self.notificationScheduler = notificationScheduler
        self.settingsRouter = settingsRouter

        let initialSelection = selectionStore.loadSelection()
        let initialPreference = Self.sanitizePreference(preferenceStore.loadPreference())
        self.selection = initialSelection
        self.preference = initialPreference
        self.characterFilter = initialPreference.defaultFilter
    }

    static func makeDefault() -> AppStore {
        AppStore(
            dataRepository: BundleGameDataRepository(),
            selectionStore: UserDefaultsSelectionStore(),
            preferenceStore: UserDefaultsPreferenceStore(),
            notificationScheduler: UNUserNotificationScheduler(),
            settingsRouter: UIApplicationSettingsRouter()
        )
    }

    func loadCatalogIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true

        do {
            catalog = try await dataRepository.loadCatalog()
            markAppOpened()
            notificationStatus = await notificationScheduler.authorizationStatus()
            if notificationStatus == .notDetermined {
                _ = await notificationScheduler.requestAuthorization()
                notificationStatus = await notificationScheduler.authorizationStatus()
            }
            await rescheduleIfPossible()
        } catch {
            errorMessage = "데이터를 불러오지 못했습니다: \(error.localizedDescription)"
        }
    }

    func refreshNotificationStatus() async {
        markAppOpened()
        notificationStatus = await notificationScheduler.authorizationStatus()
        await rescheduleIfPossible()
    }

    func toggleCharacter(_ id: String) {
        if selection.selectedCharacterIDs.contains(id) {
            selection.selectedCharacterIDs.remove(id)
            if selection.favoriteCharacterID == id {
                selection.favoriteCharacterID = nil
            }
        } else {
            guard canStartTracking() else { return }
            selection.selectedCharacterIDs.insert(id)
        }

        selectionStore.saveSelection(selection)
        // MainActor store delegates scheduling work to actor-based scheduler.
        Task { await rescheduleIfPossible() }
    }

    func toggleWeapon(_ id: String) {
        if selection.selectedWeaponIDs.contains(id) {
            selection.selectedWeaponIDs.remove(id)
            if selection.favoriteWeaponID == id {
                selection.favoriteWeaponID = nil
            }
        } else {
            guard canStartTracking() else { return }
            selection.selectedWeaponIDs.insert(id)
        }

        selectionStore.saveSelection(selection)
        // MainActor store delegates scheduling work to actor-based scheduler.
        Task { await rescheduleIfPossible() }
    }

    func setFavoriteCharacter(_ id: String) {
        guard selection.selectedCharacterIDs.contains(id) else { return }
        selection.favoriteCharacterID = (selection.favoriteCharacterID == id) ? nil : id
        selectionStore.saveSelection(selection)
        Task { await rescheduleIfPossible() }
    }

    func setFavoriteWeapon(_ id: String) {
        guard selection.selectedWeaponIDs.contains(id) else { return }
        selection.favoriteWeaponID = (selection.favoriteWeaponID == id) ? nil : id
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

    func requestNotificationAuthorization() async {
        _ = await notificationScheduler.requestAuthorization()
        notificationStatus = await notificationScheduler.authorizationStatus()
        await rescheduleIfPossible()
    }

    func openSystemSettings() {
        settingsRouter.openAppSettings()
    }

    var filteredCharacters: [Character] {
        selectedFirstCharacters(from: characterFilter.apply(to: catalog.characters))
    }

    var filteredWeapons: [Weapon] {
        selectedFirstWeapons(from: catalog.weapons.filter { weaponFilter.contains($0) })
    }

    var notificationTimeSlots: [NotificationTimeSlot] {
        sortTimeSlots(preference.timeSlots)
    }

    func date(for slot: NotificationTimeSlot) -> Date {
        var components = DateComponents()
        components.hour = slot.hour
        components.minute = slot.minute
        return Calendar.current.date(from: components) ?? Date()
    }

    func updateNotificationTime(slotID: UUID, date: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        var updated = preference.timeSlots
        guard let index = updated.firstIndex(where: { $0.id == slotID }) else { return }
        updated[index].hour = hour
        updated[index].minute = minute

        guard isValidTimeSlots(updated) else {
            errorMessage = "알림 시간 간격은 최소 4시간이어야 합니다."
            return
        }

        preference.timeSlots = sortTimeSlots(updated)
        preferenceStore.savePreference(preference)
        Task { await rescheduleIfPossible() }
    }

    func addNotificationTimeSlot() {
        guard preference.timeSlots.count < Self.maxNotificationSlots else {
            errorMessage = "알림 시간은 하루 최대 3회까지 설정할 수 있습니다."
            return
        }

        guard let newSlot = nextAvailableTimeSlot(existing: preference.timeSlots) else {
            errorMessage = "알림 시간 간격은 최소 4시간이어야 합니다."
            return
        }

        preference.timeSlots.append(newSlot)
        preference.timeSlots = sortTimeSlots(preference.timeSlots)
        preferenceStore.savePreference(preference)
        Task { await rescheduleIfPossible() }
    }

    func removeNotificationTimeSlot(_ slotID: UUID) {
        guard preference.timeSlots.count > 1 else {
            errorMessage = "최소 1개의 알림 시간이 필요합니다."
            return
        }

        preference.timeSlots.removeAll { $0.id == slotID }
        preference.timeSlots = sortTimeSlots(preference.timeSlots)
        preferenceStore.savePreference(preference)
        Task { await rescheduleIfPossible() }
    }

    private func canStartTracking() -> Bool {
        if notificationStatus == .denied {
            settingsRouter.openAppSettings()
            return false
        }
        return true
    }

    private func selectedFirstCharacters(from characters: [Character]) -> [Character] {
        let selected = characters.filter { selection.selectedCharacterIDs.contains($0.id) }
        let unselected = characters.filter { !selection.selectedCharacterIDs.contains($0.id) }
        return selected + unselected
    }

    private func selectedFirstWeapons(from weapons: [Weapon]) -> [Weapon] {
        let selected = weapons.filter { selection.selectedWeaponIDs.contains($0.id) }
        let unselected = weapons.filter { !selection.selectedWeaponIDs.contains($0.id) }
        return selected + unselected
    }

    private func markAppOpened(now: Date = Date()) {
        preference.lastAppOpenAt = now
        preferenceStore.savePreference(preference)
    }

    private func rescheduleIfPossible() async {
        guard notificationStatus.isAuthorized else { return }
        await notificationScheduler.rescheduleAll(catalog: catalog, selection: selection, preference: preference)
    }

    private static func sanitizePreference(_ preference: NotificationPreference) -> NotificationPreference {
        var sanitized = preference
        sanitized.timeSlots = sanitizeTimeSlots(preference.timeSlots)
        if sanitized.timeSlots.isEmpty {
            sanitized.timeSlots = NotificationPreference.default.timeSlots
        }
        return sanitized
    }

    private static func sanitizeTimeSlots(_ slots: [NotificationTimeSlot]) -> [NotificationTimeSlot] {
        let sorted = slots.sorted { lhs, rhs in
            if lhs.hour == rhs.hour {
                return lhs.minute < rhs.minute
            }
            return lhs.hour < rhs.hour
        }

        var deduplicated: [NotificationTimeSlot] = []
        var seen = Set<String>()
        for slot in sorted {
            let key = "\(slot.hour):\(slot.minute)"
            guard seen.insert(key).inserted else { continue }
            deduplicated.append(slot)
        }

        var filtered: [NotificationTimeSlot] = []
        for slot in deduplicated {
            guard filtered.count < Self.maxNotificationSlots else { break }
            guard let previous = filtered.last else {
                filtered.append(slot)
                continue
            }

            let diff = (slot.hour * 60 + slot.minute) - (previous.hour * 60 + previous.minute)
            if diff >= Self.minimumNotificationGapMinutes {
                filtered.append(slot)
            }
        }

        return filtered
    }

    private func isValidTimeSlots(_ slots: [NotificationTimeSlot]) -> Bool {
        guard slots.count <= Self.maxNotificationSlots else { return false }

        let sorted = sortTimeSlots(slots)
        let minutes = sorted.map { $0.hour * 60 + $0.minute }

        for index in 1..<minutes.count {
            if minutes[index] - minutes[index - 1] < Self.minimumNotificationGapMinutes {
                return false
            }
        }

        return true
    }

    private func sortTimeSlots(_ slots: [NotificationTimeSlot]) -> [NotificationTimeSlot] {
        slots.sorted { lhs, rhs in
            if lhs.hour == rhs.hour {
                return lhs.minute < rhs.minute
            }
            return lhs.hour < rhs.hour
        }
    }

    private func nextAvailableTimeSlot(existing: [NotificationTimeSlot]) -> NotificationTimeSlot? {
        for minuteOfDay in stride(from: 8 * 60, through: 22 * 60, by: 30) {
            let slot = NotificationTimeSlot(hour: minuteOfDay / 60, minute: minuteOfDay % 60)
            if isValidTimeSlots(existing + [slot]) {
                return slot
            }
        }
        return nil
    }
}
