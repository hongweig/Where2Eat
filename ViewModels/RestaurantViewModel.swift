import Foundation
import CoreLocation

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchRadius: Double = 1000
    @Published var selectedRestaurant: Restaurant?
    @Published var currentMenu: DailyMenu?
    @Published var menuLoading = false
    @Published var selectedWeekday: Weekday = Weekday.today ?? .monday

    private let service = RestaurantService()
    private var lastSearchLocation: CLLocation?

    func search(near location: CLLocation) async {
        guard shouldRefetch(for: location) else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            restaurants = try await service.searchNearby(location: location, radius: searchRadius)
            lastSearchLocation = location
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMenu(for restaurant: Restaurant, weekday: Weekday) async {
        menuLoading = true
        currentMenu = nil
        defer { menuLoading = false }
        currentMenu = await service.fetchWeeklyMenu(for: restaurant, weekday: weekday)
    }

    private func shouldRefetch(for loc: CLLocation) -> Bool {
        guard let last = lastSearchLocation else { return true }
        return loc.distance(from: last) > 200
    }
}
