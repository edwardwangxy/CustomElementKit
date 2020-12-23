//
//  VideoPlayerView.swift
//  PrivacyKeyboard
//
//  Created by Xiangyu Wang on 2/12/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//
import Foundation
import SwiftUI
import AVKit

public struct VideoPlayerView: UIViewRepresentable {
    @ObservedObject var playerUIView: PlayerUIView = PlayerUIView()
    
    public init(playerView: PlayerUIView = PlayerUIView()) {
        self.playerUIView = playerView
    }
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerView>) {
        print("video update")
    }
    
    public func makeUIView(context: Context) -> UIView {
        return self.playerUIView
    }
}

public extension VideoPlayerView {
    func setVideoGravity(mode: AVLayerVideoGravity) -> VideoPlayerView {
        self.playerUIView.updateGravity(mode: mode)
        return self
    }
    
    func mute(_ result: Bool) -> VideoPlayerView {
        self.playerUIView.playerLayer.player?.isMuted = result
        return self
    }
}

public class PlayerUIView: UIView, ObservableObject {
    public let playerLayer = AVPlayerLayer()
    
    private var timer: DispatchSourceTimer? = nil
    private var videoCanPlay: (Bool) -> Void = {_ in}
    private var videoComplete: () -> Void = {}
    private var finishObserver: Any? = nil
    
    @Published fileprivate var videoUpdate: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.player = AVQueuePlayer()
        self.layer.addSublayer(self.playerLayer)
    }
    
    public func play() {
        self.playerLayer.player?.play()
    }
    
    public func pause() {
        self.playerLayer.player?.pause()
    }
    
    public func updateGravity(mode: AVLayerVideoGravity) {
        self.playerLayer.videoGravity = mode
    }
    
    public func setVideoCanPlay(action: @escaping (Bool) -> Void) {
        self.videoCanPlay = action
    }
    
    public func setVideoComplete(action: @escaping () -> Void) {
        self.videoComplete = action
    }
    
    public func updateVideo(url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        DispatchQueue.main.async {
            self.playerLayer.player?.replaceCurrentItem(with: item)
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch(let error) {
                print("audio error: \(error.localizedDescription)")
            }
        }
        self.activateTimer()
        self.notifyViewUpdate()
    }
    
    public func removeVideo() {
        self.removePlayerObserver()
        self.playerLayer.player?.pause()
        self.playerLayer.player?.replaceCurrentItem(with: nil)
        self.notifyViewUpdate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    
}

extension PlayerUIView {
    private func observePlayerItem(item: AVPlayerItem) {
        self.activateTimer()
        self.finishObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    @objc private func finishedPlaying( _ myNotification:NSNotification) {
        print("finish playing")
        self.videoComplete()
        self.removeVideo()
    }
    
    private func removePlayerObserver() {
        self.timer?.cancel()
        if let getObserver = self.finishObserver {
            NotificationCenter.default.removeObserver(getObserver)
            self.finishObserver = nil
        }
    }
    
    private func activateTimer() {
        self.timer?.cancel()
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: 0.2)
        self.timer?.setEventHandler(handler: {
            if let keepUp = self.playerLayer.player?.currentItem?.isPlaybackLikelyToKeepUp, keepUp {
                self.videoCanPlay(true)
            } else {
                self.videoCanPlay(false)
            }
        })
        self.timer?.resume()
    }
    
    private func notifyViewUpdate() {
        DispatchQueue.main.async {
            self.videoUpdate.toggle()
        }
    }
}
