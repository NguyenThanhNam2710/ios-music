import Foundation

class YouTubePlaylistViewModel: ObservableObject {
    @Published var playlistItems: [YouTubeVideo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadPlaylist(from urlString: String) {
        guard let playlistId = extractPlaylistId(from: urlString) else {
            errorMessage = "Invalid YouTube Playlist URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        YouTubeService.shared.fetchPlaylist(playlistId: playlistId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let videos):
                    self?.playlistItems = videos
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func extractPlaylistId(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let list = queryItems.first(where: { $0.name == "list" })?.value else {
            return nil
        }
        return list
    }
}
