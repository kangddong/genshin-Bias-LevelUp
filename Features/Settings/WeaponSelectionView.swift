import SwiftUI

struct WeaponListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var searchText = ""

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                DSBackgroundLayer()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        DSCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("무기 트래커")
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColor.textPrimary)

                                Text("관심 무기를 선택해 요일 비경 알림을 받으세요.")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textSecondary)

                                Text("총 \(displayedWeapons.count)개")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(WeaponFilterMode.allCases) { mode in
                                    TagChip(
                                        text: mode.displayName,
                                        isSelected: store.weaponFilter == mode,
                                        onTap: { store.updateWeaponFilter(mode) }
                                    )
                                }
                            }
                        }

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(displayedWeapons) { weapon in
                                WeaponCatalogCardView(
                                    weapon: weapon,
                                    isSelected: store.selection.selectedWeaponIDs.contains(weapon.id),
                                    onToggle: { store.toggleWeapon(weapon.id) }
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("무기")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "무기 검색")
            .settingsToolbarSheet()
            .dsNavigationBar()
        }
    }

    private var displayedWeapons: [Weapon] {
        guard !searchText.isEmpty else { return store.filteredWeapons }
        return store.filteredWeapons.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

private struct WeaponCatalogCardView: View {
    let weapon: Weapon
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 10) {
                CardIdentitySection(
                    localImagePath: weapon.localImage,
                    imageURLs: weapon.imageCandidates,
                    title: weapon.name,
                    subtitle: "\(weapon.type.displayName) / ★\(weapon.rarity)",
                    imageSize: 56,
                    placeholderStyle: .symbol("shield.lefthalf.filled")
                ) {
                    SelectionCheckButton(isSelected: isSelected, onTap: onToggle)
                }

                if isSelected {
                    Button("추적 해제", action: onToggle)
                        .buttonStyle(DSSecondaryButtonStyle())
                } else {
                    Button("추적하기", action: onToggle)
                        .buttonStyle(DSPrimaryButtonStyle())
                }
            }
        }
    }
}
