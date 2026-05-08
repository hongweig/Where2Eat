import SwiftUI

@main
struct Where2EatApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var restaurantVM = RestaurantViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(restaurantVM)
        }
    }
}
