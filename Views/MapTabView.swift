import SwiftUI
import MapKit

struct MapTabView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var restaurantVM: RestaurantViewModel

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        latitudinalMeters: 1500,
        longitudinalMeters: 1500
    )
    @State private var selectedRestaurant: Restaurant?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: restaurantVM.restaurants) { r in
                    MapAnnotation(coordinate: r.coordinate) {
                        PinView(restaurant: r, isSelected: selectedRestaurant?.id == r.id)
                            .onTapGesture {
                                selectedRestaurant = r
                                restaurantVM.selectedRestaurant = r
                                showDetail = true
                            }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onChange(of: locationManager.location) { loc in
                    guard let loc else { return }
                    withAnimation {
                        region.center = loc.coordinate
                    }
                    Task { await restaurantVM.search(near: loc) }
                }

                // Loading indicator
                if restaurantVM.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("searching_nearby")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("app.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { RadiusPicker(radius: $restaurantVM.searchRadius) }
            .sheet(isPresented: $showDetail) {
                if let r = selectedRestaurant {
                    RestaurantDetailView(restaurant: r)
                }
            }
        }
    }
}

struct PinView: View {
    let restaurant: Restaurant
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.accentColor : .white)
                    .frame(width: 34, height: 34)
                    .shadow(radius: 3)
                Image(systemName: "fork.knife")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .accentColor)
            }
            if isSelected {
                Text(restaurant.name)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}

struct RadiusPicker: ToolbarContent {
    @Binding var radius: Double

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                ForEach([500.0, 1000.0, 2000.0, 5000.0], id: \.self) { r in
                    Button(radiusLabel(r)) { radius = r }
                }
            } label: {
                Label(radiusLabel(radius), systemImage: "scope")
                    .font(.subheadline)
            }
        }
    }

    private func radiusLabel(_ r: Double) -> String {
        r < 1000 ? "\(Int(r)) m" : "\(Int(r / 1000)) km"
    }
}
