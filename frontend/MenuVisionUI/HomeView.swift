import SwiftUI

struct HomeView: View {
    @State private var selection = 2
    var body: some View {
        TabView {
//            FirstTabView()
//            ScanView()
            ThirdTabView()
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(1)
            
            SecondTabView()
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(2)
            
//            ThirdTabView()
            ScanView()
            .tabItem {
                Label("Render", systemImage: "gearshape")
            }
            .tag(3)
        }
    }
}

#Preview {
    HomeView()
}
