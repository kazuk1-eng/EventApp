import SwiftUI
import MapKit

struct EventDetailView: View {
    let eventId: Int
    @StateObject private var viewModel = EventDetailViewModel()
    @State private var showRouteOptions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let event = viewModel.event {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text(event.category)
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                            
                            Spacer()
                            
                            if let price = event.price {
                                if price > 0 {
                                    Text("¥\(Int(price))")
                                        .font(.headline)
                                        .bold()
                                } else {
                                    Text("無料")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("日時")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            
                            Text(formatDate(event.startDatetime))
                                .font(.subheadline)
                            
                            Text("〜")
                                .font(.subheadline)
                            
                            Text(formatDate(event.endDatetime))
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("場所")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading) {
                                Text(event.location.name)
                                    .font(.subheadline)
                                
                                Text(event.location.address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let station = event.location.station {
                                    Text("最寄り駅: \(station)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("地図")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        MapView(coordinate: event.location.coordinates.clLocation)
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        showRouteOptions = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond")
                            Text("経路を表示")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showRouteOptions) {
                        if let event = viewModel.event {
                            RouteOptionsView(event: event)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("詳細")
                            .font(.headline)
                        
                        Text(event.description)
                            .font(.body)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("外部リンク")
                            .font(.headline)
                        
                        if let website = event.externalLinks.website {
                            Link(destination: website) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("公式サイト")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        
                        if let instagram = event.externalLinks.instagram {
                            Link(destination: instagram) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Instagram")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        
                        if let twitter = event.externalLinks.twitter {
                            Link(destination: twitter) {
                                HStack {
                                    Image(systemName: "bird")
                                    Text("X (Twitter)")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if let capacity = event.capacity {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("定員")
                                .font(.headline)
                            
                            Text("\(capacity)人")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                    }) {
                        HStack {
                            Image(systemName: "map")
                            Text("周辺のおすすめスポット")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text("エラーが発生しました: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("イベント情報が見つかりませんでした")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("イベント詳細")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadEventDetails(id: eventId)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "EventLocation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}

class EventDetailViewModel: ObservableObject {
    @Published var event: Event?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadEventDetails(id: Int) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchEventDetails(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] event in
                self?.event = event
            })
            .store(in: &cancellables)
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventDetailView(eventId: 1)
        }
    }
}
