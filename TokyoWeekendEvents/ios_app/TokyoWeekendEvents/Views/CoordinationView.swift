import SwiftUI
import Combine

struct CoordinationView: View {
    @StateObject private var viewModel = CoordinationViewModel()
    @State private var selectedArea: String?
    @State private var selectedPlaceType: String?
    
    private let areas = ["池袋", "新宿", "渋谷", "六本木", "お台場", "銀座", "東京", "日比谷", "丸の内", "浅草"]
    private let placeTypes = ["restaurant", "cafe", "hotel", "entertainment"]
    private let placeTypeNames = ["レストラン", "カフェ", "ホテル", "エンタメ"]
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("エリアを選択")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(areas, id: \.self) { area in
                            Button(action: {
                                selectedArea = area
                                if let area = selectedArea {
                                    viewModel.fetchNearbyPlaces(area: area, placeType: selectedPlaceType)
                                }
                            }) {
                                Text(area)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedArea == area ? ContentView.primaryColor : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedArea == area ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            
            VStack(alignment: .leading) {
                Text("場所タイプを選択")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 10) {
                    ForEach(0..<placeTypes.count, id: \.self) { index in
                        Button(action: {
                            selectedPlaceType = placeTypes[index]
                            if let area = selectedArea {
                                viewModel.fetchNearbyPlaces(area: area, placeType: selectedPlaceType)
                            }
                        }) {
                            VStack {
                                Image(systemName: getIconForPlaceType(placeTypes[index]))
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedPlaceType == placeTypes[index] ? .white : .primary)
                                    .frame(width: 50, height: 50)
                                    .background(selectedPlaceType == placeTypes[index] ? ContentView.primaryColor : Color.gray.opacity(0.1))
                                    .cornerRadius(25)
                                
                                Text(placeTypeNames[index])
                                    .font(.caption)
                                    .foregroundColor(selectedPlaceType == placeTypes[index] ? ContentView.primaryColor : .primary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            if selectedArea == nil {
                VStack {
                    Image(systemName: "map")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("エリアを選択してください")
                        .font(.headline)
                    
                    Text("周辺のおすすめスポットを表示します")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxHeight: .infinity)
            } else if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
                    .frame(maxHeight: .infinity)
            } else if let places = viewModel.places, !places.isEmpty {
                List {
                    ForEach(places) { place in
                        NearbyPlaceRow(place: place)
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("スポットが見つかりませんでした")
                        .font(.headline)
                    
                    Text("別のエリアまたはタイプを選択してください")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxHeight: .infinity)
            }
        }
        .navigationTitle("一日のコーディネート")
    }
    
    private func getIconForPlaceType(_ type: String) -> String {
        switch type {
        case "restaurant":
            return "fork.knife"
        case "cafe":
            return "cup.and.saucer"
        case "hotel":
            return "bed.double"
        case "entertainment":
            return "ticket"
        default:
            return "mappin"
        }
    }
}

struct NearbyPlaceRow: View {
    let place: NearbyPlace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(place.name)
                .font(.headline)
            
            if let description = place.description {
                Text(description)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.red)
                
                Text(place.location.area)
                    .font(.caption)
                
                if let station = place.location.station {
                    Text("・\(station)")
                        .font(.caption)
                }
                
                Spacer()
                
                if let rating = place.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .bold()
                    }
                }
            }
            
            HStack {
                Text(getPlaceTypeName(place.type))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if let priceLevel = place.priceLevel {
                    Text(String(repeating: "¥", count: priceLevel))
                        .font(.caption)
                        .bold()
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func getPlaceTypeName(_ type: String) -> String {
        switch type {
        case "restaurant":
            return "レストラン"
        case "cafe":
            return "カフェ"
        case "hotel":
            return "ホテル"
        case "entertainment":
            return "エンタメ"
        default:
            return type
        }
    }
}

class CoordinationViewModel: ObservableObject {
    @Published var places: [NearbyPlace]?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchNearbyPlaces(area: String, placeType: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchNearbyPlaces(area: area, placeType: placeType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] places in
                self?.places = places
            })
            .store(in: &cancellables)
    }
}

struct CoordinationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoordinationView()
        }
    }
}
