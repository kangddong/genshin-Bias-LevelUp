import Foundation

struct DomainAvailabilityService {
    func availableCharacters(on day: WeekdayType, catalog: GameCatalog, selectedIDs: Set<String>? = nil) -> [Character] {
        let candidates = catalog.characters.filter { character in
            guard let selectedIDs else { return true }
            return selectedIDs.contains(character.id)
        }

        return candidates
            .filter { isAvailable(materialId: $0.materialId, day: day, catalog: catalog) }
            .sorted { $0.name < $1.name }
    }

    func availableWeapons(on day: WeekdayType, catalog: GameCatalog, selectedIDs: Set<String>? = nil) -> [Weapon] {
        let candidates = catalog.weapons.filter { weapon in
            guard let selectedIDs else { return true }
            return selectedIDs.contains(weapon.id)
        }

        return candidates
            .filter { isAvailable(materialId: $0.materialId, day: day, catalog: catalog) }
            .sorted { $0.name < $1.name }
    }

    private func isAvailable(materialId: String, day: WeekdayType, catalog: GameCatalog) -> Bool {
        guard let schedule = catalog.schedulesByMaterial[materialId] else { return false }
        return schedule.weekdays.contains(day)
    }
}
