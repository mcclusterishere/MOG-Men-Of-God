import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var store: SharedStore

    var body: some View {
        Group {
            if store.didCompleteWelcome {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.didCompleteWelcome)
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Today", systemImage: "circle.grid.2x2.fill") }

            NavigationStack {
                PrivateCheckInView()
            }
            .tabItem { Label("Check In", systemImage: "heart.text.square.fill") }

            NavigationStack {
                ScrollView {
                    SafetySupportView()
                        .padding()
                }
                .background(POGBackground())
                .navigationTitle("Support now")
                .toolbarBackground(POGTheme.midnight, for: .navigationBar)
            }
            .tabItem { Label("Support", systemImage: "lifepreserver.fill") }

            NavigationStack {
                AboutView()
            }
            .tabItem { Label("About", systemImage: "info.circle.fill") }
        }
        .toolbarBackground(POGTheme.midnight, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
