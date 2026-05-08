import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject var restaurantVM: RestaurantViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedWeekday: Weekday = Weekday.today ?? .monday

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MapSnapshotHeader(coordinate: restaurant.coordinate)

                    VStack(alignment: .leading, spacing: 16) {
                        // Title & info
                        VStack(alignment: .leading, spacing: 6) {
                            Text(restaurant.name)
                                .font(.title2).fontWeight(.bold)
                            Label(restaurant.category, systemImage: "fork.knife")
                                .font(.subheadline).foregroundColor(.secondary)
                            if !restaurant.address.isEmpty {
                                Label(restaurant.address, systemImage: "mappin")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                            if let lunch = restaurant.lunchTimeText {
                                Label(lunch, systemImage: "clock")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                            if !restaurant.distanceText.isEmpty {
                                Label(restaurant.distanceText, systemImage: "figure.walk")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                        }

                        // Action buttons
                        HStack(spacing: 12) {
                            if let phone = restaurant.phone {
                                ActionButton(title: "call", icon: "phone.fill") {
                                    if let url = URL(string: "tel://\(phone)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                            if let url = restaurant.url {
                                ActionButton(title: "website", icon: "safari.fill") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            ActionButton(title: "navigate", icon: "map.fill") { openInMaps() }
                        }

                        Divider()

                        // Weekday picker
                        Text("lunch_menu_week")
                            .font(.headline)

                        WeekdayPicker(selected: $selectedWeekday)
                            .onChange(of: selectedWeekday) { day in
                                Task { await restaurantVM.loadMenu(for: restaurant, weekday: day) }
                            }

                        // Menu
                        MenuView(
                            menu: restaurantVM.currentMenu,
                            isLoading: restaurantVM.menuLoading
                        )
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") { dismiss() }
                }
            }
            .task {
                selectedWeekday = Weekday.today ?? .monday
                await restaurantVM.loadMenu(for: restaurant, weekday: selectedWeekday)
            }
        }
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: restaurant.coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = restaurant.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

// MARK: - Weekday picker

struct WeekdayPicker: View {
    @Binding var selected: Weekday

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Weekday.workdays) { day in
                let isToday = day == Weekday.today
                let isSelected = day == selected
                Button {
                    selected = day
                } label: {
                    VStack(spacing: 2) {
                        Text(day.localizedShort)
                            .font(.caption2).fontWeight(.medium)
                        if isToday {
                            Circle().fill(Color.accentColor).frame(width: 4, height: 4)
                        } else {
                            Circle().fill(Color.clear).frame(width: 4, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                    .foregroundColor(isSelected ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Reusable subviews

struct ActionButton: View {
    let title: LocalizedStringKey
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

struct MapSnapshotHeader: View {
    let coordinate: CLLocationCoordinate2D
    @State private var snapshot: UIImage?

    var body: some View {
        Group {
            if let img = snapshot {
                Image(uiImage: img).resizable().aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color(.systemGroupedBackground))
                    .overlay(ProgressView())
            }
        }
        .frame(height: 180).clipped()
        .task { snapshot = await makeSnapshot() }
    }

    private func makeSnapshot() async -> UIImage? {
        let opts = MKMapSnapshotter.Options()
        opts.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        opts.size = CGSize(width: UIScreen.main.bounds.width, height: 180)
        opts.showsBuildings = true
        return try? await MKMapSnapshotter(options: opts).start().image
    }
}
