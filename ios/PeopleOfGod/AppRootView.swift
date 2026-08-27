import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var store: SharedStore

    var body: some View {
        Group {
            if screenshotScreen == "welcome" {
                WelcomeView()
            } else if let screenshotTab {
                MainTabView(initialTab: screenshotTab)
            } else if store.didCompleteWelcome {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.didCompleteWelcome)
    }

    private var screenshotScreen: String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "-POGScreenshotScreen"),
              arguments.indices.contains(flag + 1) else {
            return nil
        }
        return arguments[flag + 1].lowercased()
    }

    private var screenshotTab: MainTab? {
        switch screenshotScreen {
        case "home": .today
        case "checkin": .checkIn
        case "support": .support
        default: nil
        }
    }
}

private enum MainTab: Hashable {
    case today
    case checkIn
    case support
    case about
}

private struct MainTabView: View {
    @State private var selection: MainTab

    init(initialTab: MainTab = .today) {
        _selection = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Today", systemImage: "circle.grid.2x2.fill") }
            .tag(MainTab.today)

            NavigationStack {
                PrivateCheckInView()
            }
            .tabItem { Label("Check In", systemImage: "heart.text.square.fill") }
            .tag(MainTab.checkIn)

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
            .tag(MainTab.support)

            NavigationStack {
                AboutView()
            }
            .tabItem { Label("About", systemImage: "info.circle.fill") }
            .tag(MainTab.about)
        }
        .toolbarBackground(POGTheme.midnight, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
