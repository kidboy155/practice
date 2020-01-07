//
//  Created by Ninja on 3/15/18.
//  Copyright © 2018 The Dark Software. All rights reserved.
//

import UIKit
import AVFoundation
import XCDYouTubeKit
import MediaPlayer

protocol IVideoPlayerView: class {
    func seekTo(time: Double, duration: Double)
    func setCurrentTimeString(_ value: String)
    func setRemainTimeString(_ value: String)
    func setPlayerState(isPlaying: Bool, updateOverlay: Bool)
    func viewHash() -> Int
    func getAVPlayerLayer() -> AVPlayerLayer
    func showLoading(isLoading: Bool)
    func setPlayerState(isPlaying: Bool)
    func updateTimeTitleWidth(withDuration duration: Double)
    func setQuality(_ qualityTitle: String)
    func bind(toViewModel vm: DSYoutubePlayerViewModel?)
    func setCanNext(_ value: Bool)
    func setCanPrev(_ value: Bool)
    func setVideoTitle(_ title: String)
}

enum DSRepeatOptions {
    case REPEAT_ONE, NO_REPEAT, AUTO_NEXT
}

struct VideoQuality {
    let name: String
    let url: URL
    
    static let preferQualities: [AnyHashable] = [
        AnyHashable(XCDYouTubeVideoQualityHTTPLiveStreaming),
        AnyHashable(XCDYouTubeVideoQuality.HD720.rawValue),
        AnyHashable(XCDYouTubeVideoQuality.medium360.rawValue),
        AnyHashable(XCDYouTubeVideoQuality.small240.rawValue)
    ]

    static func qualityString(quality: AnyHashable) -> String {
        switch quality {
        case AnyHashable(XCDYouTubeVideoQualityHTTPLiveStreaming):
            return "Live"
        case AnyHashable(XCDYouTubeVideoQuality.HD720.rawValue):
            return "720p"
        case AnyHashable(XCDYouTubeVideoQuality.medium360.rawValue):
            return "360p"
        case AnyHashable(XCDYouTubeVideoQuality.small240.rawValue):
            return "240p"
        default:
            return "unknown"
        }
    }
}

protocol DSYoutubePlayerViewModelDelegate: class {
    func playerVmRequestNextVideo(playerViewModel: DSYoutubePlayerViewModel)
    func playerVmRequestPreviousVideo(playerViewModel: DSYoutubePlayerViewModel)
    func playerVmCanNext() -> Bool
    func playerVmCanPrev() -> Bool
}

class DSYoutubePlayerViewModel: UIResponder {
    private var player = AVPlayer()
    private var views = [IVideoPlayerView]()
    
    private(set) var avaiableQualities = [VideoQuality]()
    
    private var m_video: Video? = nil
    private var m_offlineVideo: DSDownloadedVideo? = nil
    private var avPlayerStatusObserver: NSKeyValueObservation?
    private var qualityIndex = -1
    private var suppendingViews = [IVideoPlayerView]()
    private(set) var isOffline = false
    private var m_isLockUi = false
    weak var delegate: DSYoutubePlayerViewModelDelegate?

    var currentDuration = 0.0 {
        didSet {
            self.views.forEach { $0.updateTimeTitleWidth(withDuration: currentDuration) }
        }
    }
    
    var video: Video? {
        get {
            return m_video
        }
        set {
            if m_video?.id == newValue?.id {
                return
            }
            m_video = newValue
            m_offlineVideo = nil
            reloadPlayer()
        }
    }
    
    var offlineVideo: DSDownloadedVideo? {
        get {
            return m_offlineVideo
        }
        set {
            if m_offlineVideo?.identifier == newValue?.identifier { return }
            m_video = nil
            m_offlineVideo = newValue
            reloadPlayer()
        }
    }
    
    override init() {
        super.init()
        observerPlayerTime()
        handleApplicationStatus()
        handleCommandFromControl()
    }
    
    private func handleCommandFromControl() {
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            if self.player.rate == 0.0 {
                self.resume()
            }
            else {
               self.pause()
            }
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.next()
            return MPRemoteCommandHandlerStatus.success
        }
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.previous()
            return MPRemoteCommandHandlerStatus.success
        }
    }

    func requestSeek(value: Float) {
        let secs = Int64(value)
        let time = CMTime(value: secs, timescale: 1)
        player.seek(to: time)
    }

    private func observerPlayerTime() {
        player.addPeriodicTimeObserver(
            forInterval: CMTime.init(seconds: 1, preferredTimescale: 1),
            queue: DispatchQueue.main)
        { (time) in
            if self.player.rate == 0 {
                self.views.forEach{ $0.setPlayerState(isPlaying: false) }
            }
            let currentTime = CMTimeGetSeconds(time)
            let currentTimeString = currentTime.toDurationString()
            let remainTimeString = (self.currentDuration - currentTime).toDurationString()
            self.views.forEach {
                $0.seekTo(time: currentTime, duration: self.currentDuration)
                $0.setCurrentTimeString(currentTimeString)
                $0.setRemainTimeString(remainTimeString)
            }
            if currentTime >= self.currentDuration {
                self.onPaused()
            }
        }
        
        
    }
    
    private func handleApplicationStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillGoToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBackToForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func appWillGoToBackground() {
        if !DSSettingsManager.shared.playWhenBackgroud {
            player.pause()
        }
        for view in views {
            suppendingViews.append(view)
            self.removeView(view)
        }
    }
    
    @objc private func appBackToForeground() {
        for view in suppendingViews {
            self.addView(view)
        }
        suppendingViews.removeAll()
    }
    
    func addView(_ view: IVideoPlayerView) {
        objc_sync_enter(views)
        if !views.contains(where: {$0.viewHash() == view.viewHash()}) {
            view.bind(toViewModel: self)
            views.append(view)
            view.getAVPlayerLayer().player = self.player
            bindToView(view: view)
        }
        objc_sync_exit(views)
    }
    
    func removeView(_ view: IVideoPlayerView) {
        view.getAVPlayerLayer().player = nil
        objc_sync_enter(views)
        if let idx = views.index(where: {$0.viewHash() == view.viewHash()}) {
            views.remove(at: idx).bind(toViewModel: nil)
        }
        objc_sync_exit(views)
    }
    
    func resume() {
        if player.rate == 0.0 {
            var currentTime = round(CMTimeGetSeconds(player.currentTime()))
            if currentTime >= currentDuration {
                player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                currentTime = 0
            }
            let extraInfo: [String: Any] = [MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = getCurrentPlayingInfo(appendInfo: extraInfo)
            player.play()
        }
        views.forEach{ $0.setPlayerState(isPlaying: true) }
    }
    
    func requestUpdateCanNextPrev() {
        let canNextValue = delegate?.playerVmCanNext() == true
        let canPrevValue = delegate?.playerVmCanPrev() == true
        DispatchQueue.main.async {
            self.views.forEach{
                $0.setCanNext(canNextValue)
                $0.setCanPrev(canPrevValue)
            }
        }
    }
    
    private func reloadPlayer() {
        stopPlayer()
        let videoTitle = video?.snippet.title ?? offlineVideo?.videoTitle ?? "Untitled Video"
        views.forEach {
            $0.seekTo(time: 0, duration: 100)
            $0.setCurrentTimeString("00:00")
            $0.setRemainTimeString("00:00")
            $0.setQuality("")
            $0.setVideoTitle(videoTitle)
        }
        self.avaiableQualities.removeAll()

        if let video = video {
            loadOnlineVideo(video: video)
            return
        }
        if let offlineVideo = m_offlineVideo {
            loadOfflineVideo(video: offlineVideo)
        }
    }
    
    private func loadOnlineVideo(video: Video) {
        print("GET VIDEO ID: \(video.id)")
        self.isOffline = false
        views.forEach {
            $0.showLoading(isLoading: true)
        }
        XCDYouTubeClient.default().getVideoWithIdentifier(video.id) { (ytVideo: XCDYouTubeVideo?, error: Error?) in
            guard let youtubeVideo = ytVideo else {
                debugPrint("Could not get Youtube video ID: \(video.id ??? "unknow")")
                return
            }
            self.currentDuration = youtubeVideo.duration
            for quality in VideoQuality.preferQualities {
                let streamURL = youtubeVideo.streamURLs[quality]
                if let url = streamURL {
                    self.avaiableQualities.append(VideoQuality(name: VideoQuality.qualityString(quality: quality), url: url))
                }
            }
            self.qualityIndex = 0
            self.startPlay()
            UIApplication.shared.beginReceivingRemoteControlEvents()
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.getCurrentPlayingInfo()
            self.requestUpdateCanNextPrev()
        }
    }
    
    private func getCurrentPlayingInfo(appendInfo: [String: Any]? = nil) -> [String: Any] {
        let videoTitle = video?.snippet.title ?? offlineVideo?.videoTitle ?? "Untitled Video"
        var retval: [String: Any] = [MPMediaItemPropertyTitle: videoTitle,
                      MPMediaItemPropertyPlaybackDuration: self.currentDuration]
        if appendInfo != nil {
            for (k, v) in appendInfo! {
                retval[k] = v
            }
        }
        return retval
    }
    
    private func loadOfflineVideo(video: DSDownloadedVideo) {
        self.isOffline = true
        avPlayerStatusObserver?.invalidate()
        views.forEach {
            $0.setQuality("OFFLINE")
        }
        let url = URL(fileURLWithPath: DSStorageManager.shared.absolutePath(file: video.filepath!))
        let asset = AVAsset(url: url)
        self.currentDuration = CMTimeGetSeconds(asset.duration)
        let playerItem = AVPlayerItem(asset: asset)
        DispatchQueue.global().async {
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()
            UIApplication.shared.beginReceivingRemoteControlEvents()
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.getCurrentPlayingInfo()
            self.requestUpdateCanNextPrev()
        }
    }
    
    func getCurrentQualityTitle() -> String {
        if offlineVideo != nil { return "OFFLINE" }
        if qualityIndex < 0 || qualityIndex >= self.avaiableQualities.count { return "" }
        return self.avaiableQualities[qualityIndex].name
    }
    
    func setNewQuality(index: Int) {
        if index < 0 || index >= self.avaiableQualities.count || index == qualityIndex { return }
        qualityIndex = index
        let currentTime = player.currentTime()
        startPlay(from: currentTime)
    }
    
    private func stopPlayer() {
        avPlayerStatusObserver?.invalidate()
        player.replaceCurrentItem(with: nil)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    private func startPlay(from currentTime: CMTime? = nil) {
        if qualityIndex < 0 || qualityIndex > avaiableQualities.count { return }
        avPlayerStatusObserver?.invalidate()
        let url = avaiableQualities[qualityIndex].url
        views.forEach {
            $0.setQuality(avaiableQualities[qualityIndex].name)
        }
        DispatchQueue.global(qos: .background).async {
            let playerItem = AVPlayerItem(url: url)
            
            self.avPlayerStatusObserver = playerItem.observe(\.status, changeHandler: { (avPlayerItem, _) in
                self.handleAvPlayerItemStatus(avPlayerItem.status)
            })
            
            self.player.replaceCurrentItem(with: playerItem)
            if let currentTime = currentTime {
                self.player.seek(to: currentTime)
            }
            self.player.play()
        }
    }
    
    private func handleAvPlayerItemStatus(_ status: AVPlayerItemStatus) {
        if status == .readyToPlay {
            views.forEach {
                $0.showLoading(isLoading: false)
                $0.setPlayerState(isPlaying: true)
            }
        }
        else {
            views.forEach {
                $0.showLoading(isLoading: true)
                $0.setPlayerState(isPlaying: false)
            }
        }
    }
    
    func lockUserAction() -> Bool {
        if m_isLockUi { return false }
        m_isLockUi = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.m_isLockUi = false
        }
        return true
    }
    
    func isPlaying() -> Bool {
        return player.rate > 0
    }
    
    func pause() {
        player.pause()
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let extraInfo: [String: Any] = [MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = getCurrentPlayingInfo(appendInfo: extraInfo)
    }
    
    func next() {
        delegate?.playerVmRequestNextVideo(playerViewModel: self)
    }
    
    func previous() {
        delegate?.playerVmRequestPreviousVideo(playerViewModel: self)
    }
    
    func clearPlayer() {
        
    }
    
    private func onPaused() {
        if self.avaiableQualities.first?.name != "Live" {
            self.views.forEach{ $0.setPlayerState(isPlaying: false) }
            self.next()
        }
    }
    
    func bindToView(view: IVideoPlayerView) {
        view.setCurrentTimeString(player.currentTime().toStringable())
        view.updateTimeTitleWidth(withDuration: self.currentDuration)
        view.setRemainTimeString((self.currentDuration - CMTimeGetSeconds(player.currentTime())).toDurationString())
        view.setQuality(getCurrentQualityTitle())
        view.seekTo(time: CMTimeGetSeconds(player.currentTime()), duration: self.currentDuration)
        view.setPlayerState(isPlaying: isPlaying())
        let videoTitle = video?.snippet.title ?? offlineVideo?.videoTitle ?? "Untitled Video"
        view.setVideoTitle(videoTitle)
    }
}
