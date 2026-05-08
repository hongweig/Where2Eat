import MapKit
import CoreLocation

class RestaurantService {
    private lazy var lounaat = LounaatService(apiKey: Config.lounaatAPIKey)

    func searchNearby(location: CLLocation, radius: Double) async throws -> [Restaurant] {
        if !Config.lounaatAPIKey.isEmpty {
            let results = try await lounaat.nearby(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude
            )
            return results.map { $0.toRestaurant() }
        }
        return try await mapKitSearch(location: location, radius: radius)
    }

    func fetchMenu(for restaurant: Restaurant, mealPeriod: MealPeriod) async -> DailyMenu {
        guard mealPeriod == .lunch, !Config.lounaatAPIKey.isEmpty else {
            return emptyMenu(restaurant: restaurant, period: mealPeriod)
        }
        do {
            let full = try await lounaat.restaurant(id: restaurant.id)
            return full.toLunchMenu(for: Weekday.today)
        } catch {
            return emptyMenu(restaurant: restaurant, period: mealPeriod)
        }
    }

    func fetchWeeklyMenu(for restaurant: Restaurant, weekday: Weekday) async -> DailyMenu {
        guard !Config.lounaatAPIKey.isEmpty else {
            return emptyMenu(restaurant: restaurant, period: .lunch)
        }
        do {
            let full = try await lounaat.restaurant(id: restaurant.id)
            return full.toLunchMenu(for: weekday)
        } catch {
            return emptyMenu(restaurant: restaurant, period: .lunch)
        }
    }

    // MARK: - MapKit fallback

    private func mapKitSearch(location: CLLocation, radius: Double) async throws -> [Restaurant] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        let response = try await MKLocalSearch(request: request).start()
        return response.mapItems.compactMap { item in
            guard let name = item.name else { return nil }
            let coord = item.placemark.coordinate
            let dist = location.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
            return Restaurant(
                id: "\(coord.latitude),\(coord.longitude)",
                name: name,
                address: item.placemark.formattedAddress,
                coordinate: coord,
                category: NSLocalizedString("category.restaurant", comment: ""),
                phone: item.phoneNumber,
                url: item.url,
                distance: dist,
                lunchTimeText: nil
            )
        }
        .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }

    private func emptyMenu(restaurant: Restaurant, period: MealPeriod) -> DailyMenu {
        DailyMenu(restaurantId: restaurant.id, date: Date(), mealPeriod: period, sections: [])
    }
}

extension MKPlacemark {
    var formattedAddress: String {
        [subThoroughfare, thoroughfare, locality].compactMap { $0 }.joined(separator: " ")
    }
}
