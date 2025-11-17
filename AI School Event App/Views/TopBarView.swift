import SwiftUI

struct TopBarView: View {
    @Binding var selectedTab: String
    let tabs = ["AI Chat", "Feed", "Admin"]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 40) {
                ForEach(tabs, id: \.self) { tab in
                    VStack(spacing: 4) {
                        Text(tab)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .black : .gray)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.black : Color.clear)
                            .frame(height: 2)
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .background(Color.white)
        .frame(height: 60)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TopBarView(selectedTab: .constant("Feed"))
}
