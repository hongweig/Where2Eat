import Foundation
import CoreLocation

struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: String
    let phone: String?
    let url: URL?
    var distance: Double?       // meters
    var lunchTimeText: String?  // e.g. "11:00–14:00"

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool { lhs.id == rhs.id }

    var distanceText: String {
        guard let d = distance else { return "" }
        return d < 1000
            ? String(format: "%.0f m", d)
            : String(format: "%.1f km", d / 1000)
    }
}
