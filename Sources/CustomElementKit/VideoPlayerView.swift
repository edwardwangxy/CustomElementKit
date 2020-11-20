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
//    @Binding var videoURL: URL?
//    @Binding var readyToPlay: Bool
//    @State var needAspectFill: Bool = false
    @State var playerUIView = PlayerUIView()
    
    public init(url: URL, loop: Bool = false) {
        if loop {
            self.playerUIView.loopVideo(url: url)
        } else {
            self.playerUIView.updateVideo(url: url)
        }
    }
//    @State var endHandler: () -> Void = {}

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerView>) {
        print("video update")
    }
    
    public func makeUIView(context: Context) -> UIView {
//        self.playerUIView.updateComplete(handler: self.endHandler)
        return self.playerUIView
    }
}

public extension VideoPlayerView {
    func setVideoGravity(mode: AVLayerVideoGravity) -> VideoPlayerView {
        self.playerUIView.updateGravity(mode: mode)
        return self
    }
}

public class PlayerUIView: UIView {
    public var playerLayer = AVPlayerLayer()
//    public var player: AVPlayer?
    private var endHandler: () -> Void = {}
    private var observeKeepup: (AVPlayer?) -> Void = {_ in}
    var currentUrl: URL?
    var currentObserver: Any? = nil
    var finishObserver: Any? = nil
    var looper: AVPlayerLooper? = nil
    
    private var timer: DispatchSourceTimer? = nil
    public init() {
        super.init(frame: .zero)
        self.createPlayer()
    }
    
    func activateTimer() {
        self.timer?.cancel()
        self.timer = DispatchSource.makeTimerSource()
        self.timer?.schedule(deadline: .now(), repeating: 0.5)
        self.timer?.setEventHandler(handler: {
            self.observeKeepup(self.playerLayer.player)
        })
        self.timer?.resume()
    }
    
    func createPlayer(item: AVPlayerItem? = nil) {
        self.playerLayer = AVPlayerLayer()
        self.playerLayer.player = AVPlayer(playerItem: item)
        self.layer.addSublayer(self.playerLayer)
    }
    
    public func updateGravity(mode: AVLayerVideoGravity) {
        self.playerLayer.videoGravity = mode
    }
    
    public func updateComplete(handler: @escaping () -> Void) {
        self.endHandler = handler
    }
    
    public func setObserveKeepup(handler: @escaping (AVPlayer?) -> Void) {
        self.observeKeepup = handler
    }
    
    func observePlayer(item: AVPlayerItem) {
        self.activateTimer()
        self.finishObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    func removePlayerObserver() {
        self.timer?.cancel()
        if let getObserver = self.finishObserver {
            NotificationCenter.default.removeObserver(getObserver)
            self.finishObserver = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeVideo() {
        self.removePlayerObserver()
        self.playerLayer.player?.pause()
        self.playerLayer.player?.replaceCurrentItem(with: nil)
        self.playerLayer.player = nil
    }
    
    public func updateVideo(url: URL) {
        if url == self.currentUrl {
            return
        }
        self.currentUrl = url
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.playerLayer.player = AVPlayer()
        DispatchQueue.main.async {
            self.playerLayer.player?.replaceCurrentItem(with: item)
            self.observePlayer(item: item)
            self.playerLayer.player?.play()
        }
        
    }
    
    public func loopVideo(url: URL) {
        if url == self.currentUrl {
            return
        }
        self.currentUrl = url
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        self.playerLayer.player = AVQueuePlayer(items: [item])
        self.looper = AVPlayerLooper(player: self.playerLayer.player as! AVQueuePlayer, templateItem: item)
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        print("finish playing")
        
        self.endHandler()
        self.removeVideo()
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
