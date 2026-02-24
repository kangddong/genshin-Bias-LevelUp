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

            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
        }
    }
}
