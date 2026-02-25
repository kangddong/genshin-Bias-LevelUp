import SwiftUI

struct CharacterListView: View {
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
                                Text("육성 트래커")
                                    .font(DSTypography.headline)
                                    .foregroundStyle(DSColor.textPrimary)

                                Text("관심 캐릭터를 선택해 요일 비경 알림을 받으세요.")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textSecondary)

                                Text("총 \(displayedCharacters.count)명")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                        }

                        Picker("필터", selection: filterModeBinding) {
                            ForEach(CharacterFilterMode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(DSColor.primary)

                        if store.characterFilter.mode == .element {
                            chipList(
                                values: ElementType.allCases.map { ($0.displayName, $0 == store.characterFilter.element) },
                                onTap: { index in
                                    var filter = store.characterFilter
                                    filter.element = ElementType.allCases[index]
                                    store.updateCharacterFilter(filter)
                                }
                            )
                        }

                        if store.characterFilter.mode == .region {
                            chipList(
                                values: NationType.allCases.map { ($0.displayName, $0 == store.characterFilter.nation) },
                                onTap: { index in
                                    var filter = store.characterFilter
                                    filter.nation = NationType.allCases[index]
                                    store.updateCharacterFilter(filter)
                                }
                            )
                        }

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(displayedCharacters) { character in
                                CharacterCatalogCardView(
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
                    .padding()
                }
            }
            .navigationTitle("캐릭터")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "캐릭터 검색")
            .settingsToolbarNavigation()
            .dsNavigationBar()
        }
    }

    private var filterModeBinding: Binding<CharacterFilterMode> {
        Binding {
            store.characterFilter.mode
        } set: { newValue in
            var filter = store.characterFilter
            filter.mode = newValue
            switch newValue {
            case .all:
                filter.element = nil
                filter.nation = nil
            case .element:
                filter.element = filter.element ?? .anemo
                filter.nation = nil
            case .region:
                filter.nation = filter.nation ?? .mondstadt
                filter.element = nil
            }
            store.updateCharacterFilter(filter)
        }
    }

    private func chipList(values: [(String, Bool)], onTap: @escaping (Int) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, item in
                    TagChip(text: item.0, isSelected: item.1) {
                        onTap(index)
                    }
                }
            }
        }
    }

    private var displayedCharacters: [Character] {
        guard !searchText.isEmpty else { return store.filteredCharacters }
        return store.filteredCharacters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

private struct CharacterCatalogCardView: View {
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
                    imageSize: 56
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
