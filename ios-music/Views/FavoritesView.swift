import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [String] = ["Song 1", "Song 2"]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Library")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ForEach(favorites, id: \.self) { song in
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.green)
                            Text(song)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        favorites.append("New Song \(favorites.count + 1)")
                    }) {
                        Text("Add Song")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
}
