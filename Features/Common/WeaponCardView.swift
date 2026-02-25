import SwiftUI

struct WeaponCardView: View {
    let weapon: Weapon
    let isSelected: Bool
    let onToggle: () -> Void

    private let minCardHeight: CGFloat = 170

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 10) {
                CardIdentitySection(
                    localImagePath: weapon.localImage,
                    imageURLs: weapon.imageCandidates,
                    title: weapon.name,
                    subtitle: "\(weapon.type.displayName) · ★\(weapon.rarity)",
                    imageSize: 42,
                    placeholderStyle: .symbol("shield.lefthalf.filled")
                ) {
                    SelectionCheckButton(isSelected: isSelected, onTap: onToggle)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Button("추적 해제", action: onToggle)
                        .buttonStyle(DSSecondaryButtonStyle())
                } else {
                    Button("추적하기", action: onToggle)
                        .buttonStyle(DSPrimaryButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, minHeight: minCardHeight, alignment: .topLeading)
        }
    }
}
