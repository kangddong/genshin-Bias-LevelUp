import SwiftUI

struct WeaponSelectionView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        List(store.catalog.weapons) { weapon in
            HStack {
                VStack(alignment: .leading) {
                    Text(weapon.name)
                    Text("★\(weapon.rarity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(store.selection.selectedWeaponIDs.contains(weapon.id) ? "해제" : "선택") {
                    store.toggleWeapon(weapon.id)
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("무기 선택")
    }
}
