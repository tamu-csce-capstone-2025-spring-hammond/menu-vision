import SwiftUI

struct HomeView: View {

    @State private var selection = 1
    @EnvironmentObject var restaurantData: RestaurantData

    var body: some View {
        TabView(selection: $selection) {

            ScanView()
                .tabItem {
                    Label("Model Scan", systemImage: "camera")
                }
                .tag(0)
            
            NavigationStack {
                MenuScannerView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(1)

            FirstTabView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)

        }
        .accentColor(.orange300)
        /*.gesture(
            DragGesture()
                .onEnded { gesture in
                    let horizontalDrag = gesture.translation.width;
                    let verticalDrag = gesture.translation.height;
                    
                    if abs(horizontalDrag) > abs(verticalDrag) {
                        
                        if (horizontalDrag > 0){
                            //right swipe occured
                            
                            selection = (selection + selection - 1) % 3;
                            
                        }
                        else{
                            selection = (selection + 1) % 3;
                        }
                        
                    }
                }
        )*/
    }
}
