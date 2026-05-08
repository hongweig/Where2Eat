import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        Group {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                LocationPermissionView()
            case .denied, .restricted:
                LocationDeniedView()
            default:
                TabView {
                    MapTabView()
                        .tabItem {
                            Label("tab.map", systemImage: "map.fill")
                        }
                    RestaurantListView()
                        .tabItem {
                            Label("tab.list", systemImage: "list.bullet")
                        }
                }
            }
        }
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestPermission()
            }
        }
    }
}

struct LocationPermissionView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            Text("location_permission_title")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("location_permission_message")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("allow_location") {
                locationManager.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

struct LocationDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text("location_denied_title")
                .font(.title2)
                .fontWeight(.bold)
            Text("location_denied_message")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("open_settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
