import SwiftUI
import CoreLocation

struct RestaurantListView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var restaurantVM: RestaurantViewModel

    @State private var selectedRestaurant: Restaurant?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            Group {
                if restaurantVM.isLoading && restaurantVM.restaurants.isEmpty {
                    ProgressView("searching_nearby")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if restaurantVM.restaurants.isEmpty {
                    EmptyStateView()
                } else {
                    List(restaurantVM.restaurants) { r in
                        RestaurantRow(restaurant: r)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRestaurant = r
                                restaurantVM.selectedRestaurant = r
                                showDetail = true
                            }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        if let loc = locationManager.location {
                            await restaurantVM.search(near: loc)
                        }
                    }
                }
            }
            .navigationTitle("nearby_restaurants")
            .sheet(isPresented: $showDetail) {
                if let r = selectedRestaurant {
                    RestaurantDetailView(restaurant: r)
                }
            }
        }
    }
}

struct RestaurantRow: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: "fork.knife")
                    .foregroundColor(.accentColor)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(restaurant.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(restaurant.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !restaurant.distanceText.isEmpty {
                Text(restaurant.distanceText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("no_restaurants_found")
                .font(.title3)
                .fontWeight(.medium)
            if locationManager.authorizationStatus == .denied {
                Text("location_permission_needed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("open_settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
