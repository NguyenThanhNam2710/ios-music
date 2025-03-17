import SwiftUI
import CoreMedia

struct MusicPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)
                
                Text("Sample Song")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Sample Artist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                VStack(spacing: 5) {
                    Slider(value: $viewModel.currentTime, in: 0...max(viewModel.duration, 1), step: 0.1) { editing in
                        isDragging = editing
                        if !editing {
                            viewModel.seek(to: viewModel.currentTime)
                        }
                    }
                    .accentColor(.green)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let width = UIScreen.main.bounds.width - 40
                            let newTime = (value.location.x / width) * viewModel.duration
                            viewModel.currentTime = max(0, min(newTime, viewModel.duration))
                            isDragging = true
                        }
                        .onEnded { _ in
                            viewModel.seek(to: viewModel.currentTime)
                            isDragging = false
                        })
                    .disabled(viewModel.duration <= 0)
                    
                    HStack {
                        Text(formatTime(viewModel.currentTime))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(formatTime(viewModel.duration))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: { viewModel.seekBackward() }) {
                        Image(systemName: "gobackward.10")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { viewModel.togglePlayPause() }) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { viewModel.seekForward() }) {
                        Image(systemName: "goforward.10")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                Picker("Sleep Timer", selection: $viewModel.selectedSleepTime) {
                    ForEach(viewModel.sleepOptions, id: \.self) { minutes in
                        Text(minutes == 0 ? "Off" : "\(minutes) min")
                    }
                }
                .pickerStyle(.menu)
                .foregroundColor(.white)
                .accentColor(.green)
                .onChange(of: viewModel.selectedSleepTime) { oldValue, newValue in
                    viewModel.setupSleepTimer(minutes: newValue)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    MusicPlayerView(viewModel: MusicPlayerViewModel())
}
