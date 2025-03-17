import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                TextField("What do you want to listen to?", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        if !searchText.isEmpty {
                            ForEach(0..<5) { i in
                                HStack {
                                    Image(systemName: "music.note")
                                        .foregroundColor(.green)
                                    Text("Result \(i + 1): \(searchText)")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            Text("Search for songs, artists, or playlists")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
    }
}

#Preview {
    SearchView()
}
