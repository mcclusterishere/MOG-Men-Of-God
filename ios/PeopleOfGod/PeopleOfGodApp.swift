import SwiftUI

@main
struct PeopleOfGodApp: App {
    @StateObject private var store = SharedStore.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(store)
                .tint(POGTheme.warmGold)
                .preferredColorScheme(.dark)
        }
    }
}
