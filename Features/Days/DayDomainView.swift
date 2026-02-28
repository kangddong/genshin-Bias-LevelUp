import SwiftUI

private enum DayDisplayScope: String, CaseIterable, Identifiable {
    case selected
    case all
    case character
    case weapon

    var id: String { rawValue }

    var title: String {
        switch self {
        case .selected: return "선택한 대상"
        case .all: return "전체"
        case .character: return "캐릭터"
        case .weapon: return "무기"
        }
    }
}

struct DayDomainView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedDay: WeekdayType = DeviceCalendar.weekday()
    @State private var scope: DayDisplayScope = .selected
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
                                Text("오늘의 비경")
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColor.textPrimary)
                                Text("요일을 바꿔 캐릭터 특성/무기 돌파 가능 목록을 확인하세요.")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                        }

                        Picker("요일", selection: $selectedDay) {
                            ForEach(WeekdayType.ordered) { day in
                                Text(day.shortName).tag(day)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(DSColor.primary)

                        Picker("표시 대상", selection: $scope) {
                            ForEach(DayDisplayScope.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(DSColor.primary)

                        if shouldShowCharacters {
                            DSSectionHeader(title: "캐릭터 육성", trailing: "\(displayedCharacters.count)개")
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(displayedCharacters) { character in
                                    DayCharacterCardView(
                                        character: character,
                                        schedule: store.catalog.schedulesByMaterial[character.materialId],
                                        isSelected: store.selection.selectedCharacterIDs.contains(character.id),
                                        isFavorite: store.selection.favoriteCharacterID == character.id,
                                        onToggle: { store.toggleCharacter(character.id) },
                                        onToggleFavorite: { store.setFavoriteCharacter(character.id) }
                                    )
                                }
                            }
                        }

                        if shouldShowWeapons {
                            DSSectionHeader(title: "무기 돌파", trailing: "\(displayedWeapons.count)개")
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(displayedWeapons) { weapon in
                                    DayWeaponCardView(
                                        weapon: weapon,
                                        schedule: store.catalog.schedulesByMaterial[weapon.materialId],
                                        isSelected: store.selection.selectedWeaponIDs.contains(weapon.id),
                                        isFavorite: store.selection.favoriteWeaponID == weapon.id,
                                        onToggle: { store.toggleWeapon(weapon.id) },
                                        onToggleFavorite: { store.setFavoriteWeapon(weapon.id) }
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("요일 비경")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: searchPrompt
            )
            .settingsToolbarNavigation()
            .dsNavigationBar()
        }
    }

    private var shouldShowCharacters: Bool {
        scope != .weapon
    }

    private var shouldShowWeapons: Bool {
        scope != .character
    }

    private var availableCharacters: [Character] {
        let selectedIDs: Set<String>? = scope == .selected ? store.selection.selectedCharacterIDs : nil
        return store.availabilityService.availableCharacters(on: selectedDay, catalog: store.catalog, selectedIDs: selectedIDs)
    }

    private var availableWeapons: [Weapon] {
        let selectedIDs: Set<String>? = scope == .selected ? store.selection.selectedWeaponIDs : nil
        return store.availabilityService.availableWeapons(on: selectedDay, catalog: store.catalog, selectedIDs: selectedIDs)
    }

    private var displayedCharacters: [Character] {
        guard !trimmedSearchText.isEmpty else { return availableCharacters }
        return availableCharacters.filter { $0.name.localizedCaseInsensitiveContains(trimmedSearchText) }
    }

    private var displayedWeapons: [Weapon] {
        guard !trimmedSearchText.isEmpty else { return availableWeapons }
        return availableWeapons.filter { $0.name.localizedCaseInsensitiveContains(trimmedSearchText) }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var searchPrompt: String {
        switch scope {
        case .character:
            return "캐릭터 검색"
        case .weapon:
            return "무기 검색"
        case .selected, .all:
            return "캐릭터/무기 검색"
        }
    }
}

private struct DayCharacterCardView: View {
    let character: Character
    let schedule: DomainSchedule?
    let isSelected: Bool
    let isFavorite: Bool
    let onToggle: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 10) {
                CardIdentitySection(
                    localImagePath: character.localImage,
                    imageURLs: character.imageCandidates,
                    title: character.name,
                    subtitle: "\(character.element.displayName) / \(character.nation.displayName)",
                    imageSize: 42
                ) {
                    SelectionCheckButton(isSelected: isSelected, onTap: onToggle)
                }

                NavigationLink {
                    CharacterDetailView(
                        character: character,
                        schedule: schedule,
                        isSelected: isSelected,
                        onToggle: onToggle,
                        isFavorite: isFavorite,
                        onToggleFavorite: onToggleFavorite
                    )
                } label: {
                    Text("자세히 보기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DSSecondaryButtonStyle())
            }
        }
    }
}

private struct DayWeaponCardView: View {
    let weapon: Weapon
    let schedule: DomainSchedule?
    let isSelected: Bool
    let isFavorite: Bool
    let onToggle: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 10) {
                CardIdentitySection(
                    localImagePath: weapon.localImage,
                    imageURLs: weapon.imageCandidates,
                    title: weapon.name,
                    subtitle: "\(weapon.type.displayName) / ★\(weapon.rarity)",
                    imageSize: 42,
                    placeholderStyle: .symbol("shield.lefthalf.filled")
                ) {
                    SelectionCheckButton(isSelected: isSelected, onTap: onToggle)
                }

                NavigationLink {
                    WeaponDetailView(
                        weapon: weapon,
                        schedule: schedule,
                        isSelected: isSelected,
                        onToggle: onToggle,
                        isFavorite: isFavorite,
                        onToggleFavorite: onToggleFavorite
                    )
                } label: {
                    Text("자세히 보기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DSSecondaryButtonStyle())
            }
        }
    }
}
