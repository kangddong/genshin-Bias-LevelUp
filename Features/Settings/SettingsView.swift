import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            DSBackgroundLayer()

            List {
                favoriteSection

                Section {
                    LabeledContent("앱 버전", value: appVersionText)

                    NavigationLink("개인정보 처리방침") {
                        PrivacyPolicyView()
                    }
                }

                Section("알림") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        HStack {
                            Text("알림 설정")
                            Spacer()
                            Text(notificationStatusText)
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                    }

                    HStack {
                        Text("선택한 캐릭터")
                        Spacer()
                        Text("\(store.selection.selectedCharacterIDs.count)개")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textSecondary)
                    }

                    HStack {
                        Text("선택한 무기")
                        Spacer()
                        Text("\(store.selection.selectedWeaponIDs.count)개")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("마이페이지")
        .dsNavigationBar()
    }

    @ViewBuilder
    private var favoriteSection: some View {
        Section("내 최애") {
            HStack {
                Text("최애 캐릭터")
                Spacer()
                Text(favoriteCharacterName ?? "미설정")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColor.textSecondary)
            }

            HStack {
                Text("최애 무기")
                Spacer()
                Text(favoriteWeaponName ?? "미설정")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
    }

    private var favoriteCharacterName: String? {
        guard let favoriteID = store.selection.favoriteCharacterID else { return nil }
        return store.catalog.characters.first(where: { $0.id == favoriteID })?.name
    }

    private var favoriteWeaponName: String? {
        guard let favoriteID = store.selection.favoriteWeaponID else { return nil }
        return store.catalog.weapons.first(where: { $0.id == favoriteID })?.name
    }

    private var appVersionText: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(shortVersion).\(buildVersion)"
    }

    private var notificationStatusText: String {
        switch store.notificationStatus {
        case .notDetermined: return "미요청"
        case .denied: return "거부"
        case .authorized: return "허용"
        case .provisional: return "임시 허용"
        case .ephemeral: return "일시 허용"
        }
    }
}

private struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            DSBackgroundLayer()

            ScrollView {
                DSCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("개인정보 처리방침")
                            .font(DSTypography.section)
                            .foregroundStyle(DSColor.textPrimary)

                        Text("개인정보 처리방침 문서는 추후 업데이트될 예정입니다.")
                            .font(DSTypography.body)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
        .dsNavigationBar()
    }
}
