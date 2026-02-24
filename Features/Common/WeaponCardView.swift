import SwiftUI

struct WeaponCardView: View {
    let weapon: Weapon
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(weapon.name)
                    .font(.headline)
                Spacer()
                Text("★\(weapon.rarity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(isSelected ? "추적 해제" : "추적하기", action: onToggle)
                .font(.caption)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
