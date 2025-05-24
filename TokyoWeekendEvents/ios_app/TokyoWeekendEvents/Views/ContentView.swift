import SwiftUI

struct ContentView: View {
    static let primaryColor = Color(red: 0.53, green: 0.81, blue: 0.92) // Light blue
    static let secondaryColor = Color(red: 0.33, green: 0.69, blue: 0.83)
    static let accentColor = Color(red: 0.0, green: 0.48, blue: 0.71)
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                EventListView()
            }
            .tabItem {
                Label("イベント", systemImage: "calendar")
            }
            .tag(0)
            
            NavigationView {
                MapExploreView()
            }
            .tabItem {
                Label("マップ", systemImage: "map")
            }
            .tag(1)
            
            NavigationView {
                CoordinationView()
            }
            .tabItem {
                Label("コーディネート", systemImage: "star")
            }
            .tag(2)
            
            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Label("お気に入り", systemImage: "heart")
            }
            .tag(3)
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("プロフィール", systemImage: "person")
            }
            .tag(4)
        }
        .accentColor(ContentView.primaryColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
