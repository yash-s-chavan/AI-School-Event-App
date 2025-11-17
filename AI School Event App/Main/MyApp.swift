import SwiftUI

@main
struct AISchoolEventApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea(edges: .top) // 👈 just to make sure nothing wraps it in a safe container
        }
    }
}
