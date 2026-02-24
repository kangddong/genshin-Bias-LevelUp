import SwiftUI

struct CharacterListView: View {
    @EnvironmentObject private var store: AppStore
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("필터", selection: filterModeBinding) {
                        ForEach(CharacterFilterMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

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

                    Text("총 \(store.filteredCharacters.count)명")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.filteredCharacters) { character in
                            CharacterCatalogCardView(
                                character: character,
                                schedule: store.catalog.schedulesByMaterial[character.materialId],
                                isSelected: store.selection.selectedCharacterIDs.contains(character.id),
                                onToggle: { store.toggleCharacter(character.id) }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("캐릭터")
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
}

private struct CharacterCatalogCardView: View {
    let character: Character
    let schedule: DomainSchedule?
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                CharacterImageView(localImagePath: character.localImage, imageURLs: character.imageCandidates, size: 56)

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
            }

            Text(character.name)
                .font(.headline)

            Text("\(character.element.displayName) / \(character.nation.displayName)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink("자세히 보기") {
                CharacterDetailView(character: character, schedule: schedule, isSelected: isSelected, onToggle: onToggle)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
