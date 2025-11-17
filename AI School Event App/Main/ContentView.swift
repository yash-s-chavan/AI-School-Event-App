import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "Feed"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView(selectedTab: $selectedTab)
                    .padding(.top, 8)
                    .background(Color.white)
                    .frame(maxWidth: .infinity)

                Divider()

                ZStack {
                    switch selectedTab {
                    case "AI Chat":
                        AIChatView()
                    case "Admin":
                        AdminView()
                    default:
                        FeedView()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
