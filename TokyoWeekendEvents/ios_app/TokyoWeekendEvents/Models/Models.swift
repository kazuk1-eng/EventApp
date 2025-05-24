import Foundation
import CoreLocation

struct Coordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Location: Codable, Hashable {
    let name: String
    let address: String
    let coordinates: Coordinates
    let area: String
    let station: String?
}

struct ExternalLinks: Codable, Hashable {
    let website: URL?
    let instagram: URL?
    let twitter: URL?
}

struct Event: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
    let startDatetime: Date
    let endDatetime: Date
    let location: Location
    let category: String
    let externalLinks: ExternalLinks
    let price: Double?
    let capacity: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, location, category, price, capacity
        case startDatetime = "start_datetime"
        case endDatetime = "end_datetime"
        case externalLinks = "external_links"
    }
}

struct RouteOption: Codable, Identifiable, Hashable {
    var id: String { transportType }
    let transportType: String
    let durationMinutes: Int
    let distanceKm: Double
    let steps: [String]
    let estimatedCost: Double?
    
    enum CodingKeys: String, CodingKey {
        case transportType = "transport_type"
        case durationMinutes = "duration_minutes"
        case distanceKm = "distance_km"
        case steps
        case estimatedCost = "estimated_cost"
    }
}

struct NearbyPlace: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let type: String
    let location: Location
    let rating: Double?
    let priceLevel: Int?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, location, rating, description
        case priceLevel = "price_level"
    }
}

struct User: Codable, Identifiable, Hashable {
    let id: Int
    let username: String
    let email: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case isActive = "is_active"
    }
}

struct Token: Codable, Hashable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct Favorite: Codable, Identifiable, Hashable {
    let id: Int
    let userId: Int
    let eventId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventId = "event_id"
    }
}

struct Schedule: Codable, Identifiable, Hashable {
    let id: Int
    let userId: Int
    let eventId: Int
    let reminder: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case eventId = "event_id"
        case reminder
    }
}
