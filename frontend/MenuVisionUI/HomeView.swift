import SwiftUI

struct HomeView: View {
    @State private var selection = 2
    @EnvironmentObject var restaurantData: RestaurantData

    var body: some View {
        TabView {
            ThirdTabView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(1)

            ScanView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)

            FirstTabView()
                .tabItem {
                    Label("Render", systemImage: "gearshape")
                }
                .tag(3)

            NavigationStack {
                MenuScannerView()
            }
            .tabItem {
                Label("Menu", systemImage: "camera")
            }
            .tag(4)
        }
    }
}
