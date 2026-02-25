import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            DSBackgroundLayer()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DSSectionHeader(title: "알림", trailing: statusText)
                    DSCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Button("알림 권한 요청") {
                                Task {
                                    await store.requestNotificationAuthorization()
                                }
                            }
                            .buttonStyle(DSPrimaryButtonStyle())

                            HStack {
                                Text("알림 시간")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                DatePicker(
                                    "알림 시간",
                                    selection: Binding(
                                        get: { store.timeAsDate() },
                                        set: { store.updateNotificationTime(date: $0) }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("알림 요일")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textPrimary)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(WeekdayType.ordered) { day in
                                            TagChip(
                                                text: day.shortName,
                                                isSelected: store.preference.enabledWeekdays.contains(day),
                                                onTap: { store.toggleNotificationWeekday(day) }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    DSSectionHeader(title: "기본 필터", trailing: nil)
                    DSCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("모드", selection: filterModeBinding) {
                                ForEach(CharacterFilterMode.allCases) { mode in
                                    Text(mode.displayName).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(DSColor.primary)

                            if store.characterFilter.mode == .element {
                                Picker("원소", selection: elementBinding) {
                                    ForEach(ElementType.allCases) { element in
                                        Text(element.displayName).tag(Optional(element))
                                    }
                                }
                            }

                            if store.characterFilter.mode == .region {
                                Picker("지역", selection: nationBinding) {
                                    ForEach(NationType.allCases) { nation in
                                        Text(nation.displayName).tag(Optional(nation))
                                    }
                                }
                            }
                        }
                    }

                    DSSectionHeader(title: "선택 현황", trailing: nil)
                    DSCard {
                        VStack(spacing: 12) {
                            HStack {
                                Text("선택한 캐릭터")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                Text("\(store.selection.selectedCharacterIDs.count)개")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColor.textSecondary)
                            }

                            HStack {
                                Text("선택한 무기")
                                    .font(DSTypography.body)
                                    .foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                Text("\(store.selection.selectedWeaponIDs.count)개")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("설정")
        .dsNavigationBar()
    }

    private var statusText: String {
        switch store.notificationStatus {
        case .notDetermined: return "미요청"
        case .denied: return "거부"
        case .authorized: return "허용"
        case .provisional: return "임시 허용"
        case .ephemeral: return "일시 허용"
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

    private var elementBinding: Binding<ElementType?> {
        Binding {
            store.characterFilter.element
        } set: { value in
            var filter = store.characterFilter
            filter.element = value
            store.updateCharacterFilter(filter)
        }
    }

    private var nationBinding: Binding<NationType?> {
        Binding {
            store.characterFilter.nation
        } set: { value in
            var filter = store.characterFilter
            filter.nation = value
            store.updateCharacterFilter(filter)
        }
    }
}
