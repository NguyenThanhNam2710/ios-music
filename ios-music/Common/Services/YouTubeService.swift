import Foundation

class YouTubeService {
    static let shared = YouTubeService()
    private let apiKey = "YOUR_YOUTUBE_API_KEY" // Thay bằng API Key của bạn
    private let baseURL = "https://www.googleapis.com/youtube/v3/playlistItems"
    
    func fetchPlaylist(playlistId: String, completion: @escaping (Result<[YouTubeVideo], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?part=snippet&maxResults=10&playlistId=\(playlistId)&key=\(apiKey)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(YouTubePlaylistResponse.self, from: data)
                let videos = response.items.map { item in
                    YouTubeVideo(
                        id: item.snippet.resourceId.videoId,
                        title: item.snippet.title,
                        thumbnailURL: item.snippet.thumbnails.medium.url
                    )
                }
                completion(.success(videos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
