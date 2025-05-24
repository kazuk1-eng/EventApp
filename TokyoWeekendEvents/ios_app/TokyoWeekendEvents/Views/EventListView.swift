import SwiftUI

struct EventListView: View {
    @StateObject private var viewModel = EventListViewModel()
    @State private var showFilters = false
    @State private var selectedArea: String?
    @State private var selectedStation: String?
    @State private var selectedStartDate: Date?
    @State private var selectedEndDate: Date?
    @State private var selectedCategory: String?
    
    private let areas = ["上野", "渋谷", "池袋", "新宿", "北千住"]
    private let categories = ["アート", "音楽", "フード", "アニメ", "マーケット"]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("フィルター")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        showFilters.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                if showFilters {
                    VStack(spacing: 10) {
                        HStack {
                            Text("エリア:")
                                .font(.subheadline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(areas, id: \.self) { area in
                                        Button(action: {
                                            if selectedArea == area {
                                                selectedArea = nil
                                            } else {
                                                selectedArea = area
                                            }
                                            viewModel.filterEvents(area: selectedArea, station: selectedStation, 
                                                                  startDate: selectedStartDate, endDate: selectedEndDate, 
                                                                  category: selectedCategory)
                                        }) {
                                            Text(area)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(selectedArea == area ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(selectedArea == area ? .white : .primary)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Text("カテゴリー:")
                                .font(.subheadline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(categories, id: \.self) { category in
                                        Button(action: {
                                            if selectedCategory == category {
                                                selectedCategory = nil
                                            } else {
                                                selectedCategory = category
                                            }
                                            viewModel.filterEvents(area: selectedArea, station: selectedStation, 
                                                                  startDate: selectedStartDate, endDate: selectedEndDate, 
                                                                  category: selectedCategory)
                                        }) {
                                            Text(category)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Text("期間:")
                                .font(.subheadline)
                            
                            DatePicker("開始", selection: Binding(
                                get: { selectedStartDate ?? Date() },
                                set: { selectedStartDate = $0 }
                            ), displayedComponents: .date)
                            
                            DatePicker("終了", selection: Binding(
                                get: { selectedEndDate ?? Date() },
                                set: { selectedEndDate = $0 }
                            ), displayedComponents: .date)
                            
                            Button(action: {
                                viewModel.filterEvents(area: selectedArea, station: selectedStation, 
                                                      startDate: selectedStartDate, endDate: selectedEndDate, 
                                                      category: selectedCategory)
                            }) {
                                Text("適用")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button(action: {
                            selectedArea = nil
                            selectedStation = nil
                            selectedStartDate = nil
                            selectedEndDate = nil
                            selectedCategory = nil
                            viewModel.filterEvents()
                        }) {
                            Text("フィルターをリセット")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                } else if viewModel.events.isEmpty {
                    VStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("イベントが見つかりませんでした")
                            .font(.headline)
                        
                        Text("フィルターを変更して再度お試しください")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.events) { event in
                            NavigationLink(destination: EventDetailView(eventId: event.id)) {
                                EventRowView(event: event)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.filterEvents(area: selectedArea, station: selectedStation, 
                                              startDate: selectedStartDate, endDate: selectedEndDate, 
                                              category: selectedCategory)
                    }
                }
            }
            .navigationTitle("東京週末イベント")
            .onAppear {
                viewModel.loadEvents()
            }
        }
    }
}

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.name)
                .font(.headline)
            
            Text(event.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.red)
                
                Text(event.location.area)
                    .font(.caption)
                
                if let station = event.location.station {
                    Text("・\(station)")
                        .font(.caption)
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                
                Text(formatDate(event.startDatetime))
                    .font(.caption)
            }
            
            HStack {
                Text(event.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if let price = event.price {
                    if price > 0 {
                        Text("¥\(Int(price))")
                            .font(.caption)
                            .bold()
                    } else {
                        Text("無料")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
    
    func filterEvents(area: String? = nil, station: String? = nil, 
                     startDate: Date? = nil, endDate: Date? = nil, 
                     category: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchEvents(area: area, station: station, 
                                     startDate: startDate, endDate: endDate, 
                                     category: category)
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

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
