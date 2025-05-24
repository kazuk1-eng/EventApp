import SwiftUI
import MapKit

struct MapExploreView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671), // Tokyo
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @StateObject private var viewModel = MapExploreViewModel()
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: viewModel.events) { event in
                MapAnnotation(coordinate: event.location.coordinates.clLocation) {
                    NavigationLink(destination: EventDetailView(eventId: event.id)) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(ContentView.primaryColor)
                            
                            Text(event.name)
                                .font(.caption)
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(5)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.areas, id: \.self) { area in
                        Button(action: {
                            viewModel.selectedArea = viewModel.selectedArea == area ? nil : area
                            viewModel.filterEvents()
                        }) {
                            Text(area)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedArea == area ? ContentView.primaryColor : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.selectedArea == area ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
            }
            .background(Color.white)
        }
        .navigationTitle("イベントマップ")
        .onAppear {
            viewModel.loadEvents()
        }
    }
}

class MapExploreViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedArea: String?
    
    let areas = ["池袋", "新宿", "渋谷", "六本木", "お台場", "銀座", "東京", "日比谷", "丸の内", "浅草"]
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadEvents() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchEvents()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] events in
                self?.events = events
            })
            .store(in: &cancellables)
    }
    
    func filterEvents() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchEvents(area: selectedArea)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] events in
                self?.events = events
            })
            .store(in: &cancellables)
    }
}

struct MapExploreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapExploreView()
        }
    }
}
