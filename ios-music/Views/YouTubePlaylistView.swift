import SwiftUI

struct YouTubePlaylistView: View {
    @ObservedObject var viewModel: YouTubePlaylistViewModel
    @State private var playlistURL = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Playlists")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                TextField("Enter YouTube Playlist URL", text: $playlistURL)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: { viewModel.loadPlaylist(from: playlistURL) }) {
                    Text("Load Playlist")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        ForEach(viewModel.playlistItems) { item in
                            HStack {
                                AsyncImage(url: URL(string: item.thumbnailURL)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                                
                                Text(item.title)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    YouTubePlaylistView(viewModel: YouTubePlaylistViewModel())
}
