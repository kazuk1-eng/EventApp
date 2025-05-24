import SwiftUI
import CoreLocation

struct RouteOptionsView: View {
    let event: Event
    @StateObject private var viewModel = RouteOptionsViewModel()
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var selectedTransportType: String?
    
    private let locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            HStack {
                Text("経路オプション")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    if userLocation == nil {
                        locationManager.requestWhenInUseAuthorization()
                        locationManager.requestLocation()
                    }
                }) {
                    Image(systemName: "location.circle")
                        .font(.title2)
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("目的地")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading) {
                        Text(event.location.name)
                            .font(.headline)
                        
                        Text(event.location.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    TransportTypeButton(
                        type: "walking",
                        icon: "figure.walk",
                        label: "徒歩",
                        isSelected: selectedTransportType == "walking",
                        action: {
                            selectedTransportType = "walking"
                            if let location = userLocation {
                                viewModel.fetchRoutes(
                                    eventId: event.id,
                                    fromLat: location.latitude,
                                    fromLng: location.longitude,
                                    transportTypes: ["walking"]
                                )
                            }
                        }
                    )
                    
                    TransportTypeButton(
                        type: "transit",
                        icon: "tram.fill",
                        label: "電車",
                        isSelected: selectedTransportType == "transit",
                        action: {
                            selectedTransportType = "transit"
                            if let location = userLocation {
                                viewModel.fetchRoutes(
                                    eventId: event.id,
                                    fromLat: location.latitude,
                                    fromLng: location.longitude,
                                    transportTypes: ["transit"]
                                )
                            }
                        }
                    )
                    
                    TransportTypeButton(
                        type: "driving",
                        icon: "car.fill",
                        label: "車",
                        isSelected: selectedTransportType == "driving",
                        action: {
                            selectedTransportType = "driving"
                            if let location = userLocation {
                                viewModel.fetchRoutes(
                                    eventId: event.id,
                                    fromLat: location.latitude,
                                    fromLng: location.longitude,
                                    transportTypes: ["driving"]
                                )
                            }
                        }
                    )
                    
                    TransportTypeButton(
                        type: "bicycle",
                        icon: "bicycle",
                        label: "自転車",
                        isSelected: selectedTransportType == "bicycle",
                        action: {
                            selectedTransportType = "bicycle"
                            if let location = userLocation {
                                viewModel.fetchRoutes(
                                    eventId: event.id,
                                    fromLat: location.latitude,
                                    fromLng: location.longitude,
                                    transportTypes: ["bicycle"]
                                )
                            }
                        }
                    )
                    
                    TransportTypeButton(
                        type: "taxi",
                        icon: "car.circle",
                        label: "タクシー",
                        isSelected: selectedTransportType == "taxi",
                        action: {
                            selectedTransportType = "taxi"
                            if let location = userLocation {
                                viewModel.fetchRoutes(
                                    eventId: event.id,
                                    fromLat: location.latitude,
                                    fromLng: location.longitude,
                                    transportTypes: ["taxi"]
                                )
                            }
                        }
                    )
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            if userLocation == nil {
                VStack {
                    Image(systemName: "location.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("現在地が取得できません")
                        .font(.headline)
                    
                    Text("位置情報へのアクセスを許可してください")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        locationManager.requestWhenInUseAuthorization()
                        locationManager.requestLocation()
                    }) {
                        Text("位置情報を取得")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            } else if let routes = viewModel.routes, !routes.isEmpty {
                List {
                    ForEach(routes) { route in
                        RouteOptionRow(route: route)
                    }
                }
            } else if viewModel.errorMessage != nil {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("経路情報の取得に失敗しました")
                        .font(.headline)
                    
                    Text("別の交通手段を試すか、後でもう一度お試しください")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            } else if selectedTransportType != nil {
                VStack {
                    Image(systemName: "map")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("経路が見つかりませんでした")
                        .font(.headline)
                    
                    Text("別の交通手段を試してください")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                VStack {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text("交通手段を選択してください")
                        .font(.headline)
                }
                .padding()
            }
            
            Spacer()
        }
        .onAppear {
            setupLocationManager()
        }
    }
    
    private func setupLocationManager() {
        userLocation = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
        
    }
}

struct TransportTypeButton: View {
    let type: String
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                    .cornerRadius(25)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
    }
}

struct RouteOptionRow: View {
    let route: RouteOption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: getTransportIcon(route.transportType))
                    .foregroundColor(.blue)
                
                Text(getTransportName(route.transportType))
                    .font(.headline)
                
                Spacer()
                
                Text("\(route.durationMinutes)分")
                    .font(.headline)
            }
            
            Text("\(String(format: "%.1f", route.distanceKm))km")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let cost = route.estimatedCost {
                if cost > 0 {
                    Text("料金: ¥\(Int(cost))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("料金: 無料")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                ForEach(route.steps, id: \.self) { step in
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                        
                        Text(step)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 8)
    }
    
    private func getTransportIcon(_ type: String) -> String {
        switch type {
        case "walking":
            return "figure.walk"
        case "driving":
            return "car.fill"
        case "transit":
            return "tram.fill"
        case "bicycle":
            return "bicycle"
        case "taxi":
            return "car.circle"
        default:
            return "map"
        }
    }
    
    private func getTransportName(_ type: String) -> String {
        switch type {
        case "walking":
            return "徒歩"
        case "driving":
            return "車"
        case "transit":
            return "電車"
        case "bicycle":
            return "自転車"
        case "taxi":
            return "タクシー"
        default:
            return type
        }
    }
}

class RouteOptionsViewModel: ObservableObject {
    @Published var routes: [RouteOption]?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchRoutes(eventId: Int, fromLat: Double, fromLng: Double, transportTypes: [String]) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchRoutes(eventId: eventId, fromLat: fromLat, fromLng: fromLng, transportTypes: transportTypes)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] routes in
                self?.routes = routes
            })
            .store(in: &cancellables)
    }
}

struct RouteOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockEvent = Event(
            id: 1,
            name: "東京アートフェスティバル",
            description: "週末に開催される東京最大のアートフェスティバル。",
            startDatetime: Date(),
            endDatetime: Date().addingTimeInterval(3600 * 8),
            location: Location(
                name: "上野公園",
                address: "東京都台東区上野公園",
                coordinates: Coordinates(latitude: 35.7151, longitude: 139.7734),
                area: "上野",
                station: "上野駅"
            ),
            category: "アート",
            externalLinks: ExternalLinks(
                website: URL(string: "https://example.com"),
                instagram: nil,
                twitter: nil
            ),
            price: 1000,
            capacity: 5000
        )
        
        return RouteOptionsView(event: mockEvent)
    }
}
