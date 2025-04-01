import SwiftUI

struct HomeView: View {
    @State private var selection = 2

    var body: some View {
        TabView {

            ScanView()
                .tabItem {
                    Label("Model Scan", systemImage: "camera")
                }
                .tag(2)
            
            NavigationStack {
                MenuScannerView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(4)

            FirstTabView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)

        }
    }
}

#Preview {
    HomeView()
}
