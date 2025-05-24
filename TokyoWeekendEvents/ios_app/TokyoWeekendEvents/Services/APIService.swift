import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case authenticationError
    case serverError(String)
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8000"
    private let jsonDecoder: JSONDecoder
    private var authToken: String?
    
    private init() {
        jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        authToken = UserDefaults.standard.string(forKey: "authToken")
    }
    
    
    func login(email: String, password: String) -> AnyPublisher<User, APIError> {
        guard let url = URL(string: "\(baseURL)/token") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "username=\(email)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: Token.self, decoder: jsonDecoder)
            .flatMap { token -> AnyPublisher<User, APIError> in
                self.authToken = token.access_token
                UserDefaults.standard.set(token.access_token, forKey: "authToken")
                
                return self.fetchCurrentUser()
            }
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<User, APIError> {
        guard let url = URL(string: "\(baseURL)/users/register") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData = UserCreate(username: username, email: email, password: password)
        
        do {
            request.httpBody = try JSONEncoder().encode(userData)
        } catch {
            return Fail(error: APIError.networkError(error)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: User.self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCurrentUser() -> AnyPublisher<User, APIError> {
        guard let token = authToken else {
            return Fail(error: APIError.authenticationError).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/users/me") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: User.self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func logout() {
        authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    
    func fetchEvents(area: String? = nil, station: String? = nil, 
                    startDate: Date? = nil, endDate: Date? = nil, 
                    category: String? = nil) -> AnyPublisher<[Event], APIError> {
        
        var urlComponents = URLComponents(string: "\(baseURL)/events")
        var queryItems: [URLQueryItem] = []
        
        if let area = area {
            queryItems.append(URLQueryItem(name: "area", value: area))
        }
        
        if let station = station {
            queryItems.append(URLQueryItem(name: "station", value: station))
        }
        
        if let startDate = startDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "start_date", value: dateFormatter.string(from: startDate)))
        }
        
        if let endDate = endDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(URLQueryItem(name: "end_date", value: dateFormatter.string(from: endDate)))
        }
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: [Event].self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func searchEvents(query: String) -> AnyPublisher<[Event], APIError> {
        guard var urlComponents = URLComponents(string: "\(baseURL)/events/search") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "query", value: query)]
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: [Event].self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchEventDetails(id: Int) -> AnyPublisher<Event, APIError> {
        guard let url = URL(string: "\(baseURL)/events/\(id)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: Event.self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRoutes(eventId: Int, fromLat: Double, fromLng: Double, 
                    transportTypes: [String] = ["walking", "driving", "transit"]) -> AnyPublisher<[RouteOption], APIError> {
        
        let transportTypesString = transportTypes.joined(separator: ",")
        
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/routes?from_lat=\(fromLat)&from_lng=\(fromLng)&transport_types=\(transportTypesString)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: [RouteOption].self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchNearbyPlaces(area: String, placeType: String? = nil) -> AnyPublisher<[NearbyPlace], APIError> {
        var urlComponents = URLComponents(string: "\(baseURL)/nearby/\(area)")
        
        if let placeType = placeType {
            urlComponents?.queryItems = [URLQueryItem(name: "place_type", value: placeType)]
        }
        
        guard let url = urlComponents?.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: [NearbyPlace].self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    func fetchFavorites() -> AnyPublisher<[Event], APIError> {
        guard let token = authToken else {
            return Fail(error: APIError.authenticationError).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/users/favorites") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: [Event].self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func addFavorite(eventId: Int) -> AnyPublisher<Favorite, APIError> {
        guard let token = authToken else {
            return Fail(error: APIError.authenticationError).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/favorite") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: Favorite.self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func removeFavorite(eventId: Int) -> AnyPublisher<Void, APIError> {
        guard let token = authToken else {
            return Fail(error: APIError.authenticationError).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/favorite") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { _ in () }
            .mapError { error -> APIError in
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    
    func fetchSchedule() -> AnyPublisher<[Event], APIError> {
        guard let token = authToken else {
            return Fail(error: APIError.authenticationError).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/users/schedule") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: [Event].self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func addToSchedule(eventId: Int, reminder: Bool = false) -> AnyPublisher<Schedule, APIError> {
        guard let token = authToken else {
            return Fail(error: APIError.authenticationError).eraseToAnyPublisher()
        }
        
        guard var urlComponents = URLComponents(string: "\(baseURL)/events/\(eventId)/schedule") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "reminder", value: reminder ? "true" : "false")]
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { $0.data }
            .decode(type: Schedule.self, decoder: jsonDecoder)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    return APIError.decodingError(decodingError)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func removeFromSchedule(eventId: Int) -> AnyPublisher<Void, APIError> {
        guard let token = authToken else {
            return Fail(error: APIError.authenticationError).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/schedule") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { APIError.networkError($0) }
            .map { _ in () }
            .mapError { error -> APIError in
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
}


struct Token: Codable {
    let access_token: String
    let token_type: String
}

struct UserCreate: Codable {
    let username: String
    let email: String
    let password: String
}
