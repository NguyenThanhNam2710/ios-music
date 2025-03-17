import Foundation
import AVFoundation
import MediaPlayer

@MainActor
class MusicPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var selectedSleepTime = 0
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    private var player: AVPlayer?
    private var sleepTimer: Timer?
    private var timeObserver: Any?
    let sleepOptions = [0, 5, 10, 15, 30, 60]
    
    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    func togglePlayPause() {
        if player == nil {
            let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            
            if isPlaying {
                player?.play()
            }
            
            setupTimeObserver()
            
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let durationValue = try await playerItem.asset.load(.duration)
                    let durationSeconds = durationValue.seconds
                    if !durationSeconds.isNaN, durationSeconds > 0 {
                        self.duration = durationSeconds
                        self.updateNowPlayingInfo()
                    }
                } catch {
                    print("Failed to load duration: \(error)")
                }
            }
        }
        
        isPlaying.toggle()
        if isPlaying {
            player?.play()
        } else {
            player?.pause()
        }
        updateNowPlayingInfo()
    }
    
    func seekForward() {
        guard let player = player else { return }
        let newTime = min(currentTime + 10, duration)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
        checkIfEnded(newTime)
        updateNowPlayingInfo()
    }
    
    func seekBackward() {
        guard let player = player else { return }
        let newTime = max(currentTime - 10, 0)
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
        updateNowPlayingInfo()
    }
    
    func seek(to seconds: Double) {
        guard let player = player else { return }
        let clampedTime = max(0, min(seconds, duration))
        let newTime = CMTime(seconds: clampedTime, preferredTimescale: 1)
        player.seek(to: newTime)
        currentTime = clampedTime
        checkIfEnded(clampedTime)
        updateNowPlayingInfo()
    }
    
    func setupSleepTimer(minutes: Int) {
        sleepTimer?.invalidate()
        if minutes > 0 {
            let seconds = Double(minutes * 60)
            sleepTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
                self?.player?.pause()
                self?.isPlaying = false
                self?.selectedSleepTime = 0
                self?.updateNowPlayingInfo()
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, !time.seconds.isNaN else { return }
            self.currentTime = min(time.seconds, self.duration)
            self.checkIfEnded(self.currentTime)
            self.updateNowPlayingInfo()
        }
    }
    
    private func checkIfEnded(_ time: Double) {
        if time >= duration - 0.1 { // Dung sai 0.1 giây
            player?.pause()
            isPlaying = false
            currentTime = duration
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.isPlaying = true
            self?.player?.play()
            self?.updateNowPlayingInfo()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.isPlaying = false
            self?.player?.pause()
            self?.updateNowPlayingInfo()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            print("Next track")
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            print("Previous track")
            return .success
        }
        
        commandCenter.seekForwardCommand.addTarget { [weak self] _ in
            self?.seekForward()
            return .success
        }
        
        commandCenter.seekBackwardCommand.addTarget { [weak self] _ in
            self?.seekBackward()
            return .success
        }
        
        // Thêm hỗ trợ tua (seek) từ thanh tiến trình ở Control Center/Lock Screen
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let newTime = positionEvent.positionTime
            self.seek(to: newTime)
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Sample Song"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Sample Artist"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        if let image = UIImage(systemName: "music.note") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
}
