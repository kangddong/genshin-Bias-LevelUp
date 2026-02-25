import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    let schedule: DomainSchedule?
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        TrackableMaterialDetailView(
            localImagePath: character.localImage,
            imageURLs: character.imageCandidates,
            title: character.name,
            subtitle: "\(character.element.displayName) / \(character.nation.displayName)",
            materialSectionTitle: "특성 재료",
            schedule: schedule,
            isSelected: isSelected,
            onToggle: onToggle
        )
    }
}
