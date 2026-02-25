import SwiftUI

struct WeaponDetailView: View {
    let weapon: Weapon
    let schedule: DomainSchedule?
    let isSelected: Bool
    let onToggle: () -> Void
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        TrackableMaterialDetailView(
            localImagePath: weapon.localImage,
            imageURLs: weapon.imageCandidates,
            title: weapon.name,
            subtitle: "\(weapon.type.displayName) / ★\(weapon.rarity)",
            placeholderStyle: .symbol("shield.lefthalf.filled"),
            materialSectionTitle: "돌파 재료",
            schedule: schedule,
            isSelected: isSelected,
            onToggle: onToggle,
            isFavorite: isFavorite,
            onToggleFavorite: onToggleFavorite
        )
    }
}
