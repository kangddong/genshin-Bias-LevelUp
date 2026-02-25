import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            CharacterListView()
                .tabItem {
                    Label("캐릭터", systemImage: "person.3")
                }

            DayDomainView()
                .tabItem {
                    Label("요일 비경", systemImage: "calendar")
                }

            WeaponListView()
                .tabItem {
                    Label("무기", systemImage: "shield.lefthalf.filled")
                }
        }
        .tint(DSColor.primary)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(DSColor.panelStrong, for: .tabBar)
    }
}
