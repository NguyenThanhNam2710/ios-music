import SwiftUI

extension Notification.Name {
    static let logout = Notification.Name("logout")
}

struct ContentView: View {
    @ObservedObject var loginViewModel = LoginViewModel()
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @State private var showNetworkError = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if loginViewModel.isLoggedIn {
                TabView {
                    MusicPlayerView(viewModel: MusicPlayerViewModel())
                        .tabItem { Label("Home", systemImage: "house.fill") }
                    SearchView()
                        .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    FavoritesView()
                        .tabItem { Label("Your Library", systemImage: "heart.fill") }
                    YouTubePlaylistView(viewModel: YouTubePlaylistViewModel())
                        .tabItem { Label("Playlists", systemImage: "music.note.list") }
                }
                .accentColor(.green)
            } else {
                LoginView(viewModel: loginViewModel)
            }
        }
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            showNetworkError = !newValue // Hiển thị khi mất mạng
        }
        .alert("No Internet Connection", isPresented: $showNetworkError) {
            Button("OK") {
                showNetworkError = false
            }
        } message: {
            Text("Please check your network connection and try again.")
        }
        .onReceive(NotificationCenter.default.publisher(for: .logout)) { _ in
            loginViewModel.logout()
        }
    }
}

#Preview {
    ContentView()
}
