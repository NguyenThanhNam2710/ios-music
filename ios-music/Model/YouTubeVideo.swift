import Foundation

struct YouTubeVideo: Identifiable, Codable {
    let id: String
    let title: String
    let thumbnailURL: String
    
    enum CodingKeys: String, CodingKey {
        case id = "videoId"
        case title
        case thumbnailURL = "thumbnail"
    }
}

struct YouTubePlaylistResponse: Codable {
    let items: [YouTubePlaylistItem]
}

struct YouTubePlaylistItem: Codable {
    let snippet: Snippet
    
    struct Snippet: Codable {
        let title: String
        let resourceId: ResourceId
        let thumbnails: Thumbnails
        
        struct ResourceId: Codable {
            let videoId: String
        }
        
        struct Thumbnails: Codable {
            let medium: Thumbnail
            
            struct Thumbnail: Codable {
                let url: String
            }
        }
    }
}
