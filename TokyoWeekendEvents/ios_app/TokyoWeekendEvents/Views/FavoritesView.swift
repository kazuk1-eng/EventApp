import SwiftUI
import Combine

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedCategory: String?
    
    private let categories = ["すべて", "アート", "音楽", "フード", "アニメ", "マーケット"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category == "すべて" ? nil : category
                            viewModel.filterFavorites(category: selectedCategory)
                        }) {
                            Text(category)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(
                                    (selectedCategory == category) || 
                                    (category == "すべて" && selectedCategory == nil) ? 
                                    ContentView.primaryColor : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(
                                    (selectedCategory == category) || 
                                    (category == "すべて" && selectedCategory == nil) ? 
                                    .white : .primary
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
                    .frame(maxHeight: .infinity)
            } else if viewModel.favorites.isEmpty {
                VStack {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("お気に入りがありません")
                        .font(.headline)
                    
                    Text("イベントをお気に入りに追加すると、ここに表示されます")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                    }) {
                        Text("イベントを探す")
                            .padding()
                            .background(ContentView.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.favorites) { event in
                        NavigationLink(destination: EventDetailView(eventId: event.id)) {
                            EventRowView(event: event)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.removeFavorite(event: event)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    viewModel.loadFavorites()
                }
            }
        }
        .navigationTitle("お気に入り")
        .onAppear {
            viewModel.loadFavorites()
        }
    }
}

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var allFavorites: [Event] = []
    private var cancellables = Set<AnyCancellable>()
    
    func loadFavorites() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchFavorites()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] events in
                guard let self = self else { return }
                self.allFavorites = events
                self.filterFavorites(category: nil)
            })
            .store(in: &cancellables)
    }
    
    func filterFavorites(category: String? = nil) {
        if let category = category {
            favorites = allFavorites.filter { $0.category == category }
        } else {
            favorites = allFavorites
        }
    }
    
    func removeFavorite(event: Event) {
        isLoading = true
        
        APIService.shared.removeFavorite(eventId: event.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] success in
                guard let self = self, success else { return }
                self.allFavorites.removeAll { $0.id == event.id }
                self.filterFavorites(category: nil)
            })
            .store(in: &cancellables)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FavoritesView()
        }
    }
}
