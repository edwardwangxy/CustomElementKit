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

public class PIPController: NSObject, AVPictureInPictureControllerDelegate {
    public var pipController: AVPictureInPictureController?
    public var stateUpdate: (Bool) -> Void = {_ in}
    public var restoreAction: () -> Void = {}
    public var pipWillStart: () -> Void = {}
    public var pipDidStart: () -> Void = {}
    public var pipWillEnd: () -> Void = {}
    public var pipDidEnd: () -> Void = {}
    public var pipFailed: (Error) -> Void = {_ in}
    
    var pipPossibleObservation: NSKeyValueObservation?
    
    public init(layer: AVPlayerLayer) {
        super.init()
        self.setupPictureInPicture(layer: layer)
    }
    
    public override init() {
        super.init()
    }
    
    public func onPlayingStateUpdate(action: @escaping (Bool) -> Void) {
        self.stateUpdate = action
    }
    
    public func activePIP() {
        if self.pipController?.isPictureInPicturePossible ?? false && !(self.pipController?.isPictureInPictureActive ?? false) {
            self.pipController?.startPictureInPicture()
        } else {
            
        }
    }
    
    public func stopPIP() {
        if self.pipController?.isPictureInPictureActive ?? false {
            self.pipController?.stopPictureInPicture()
        }
    }
    
    public func onPIPStartFailed(action: @escaping (Error) -> Void) {
        self.pipFailed = action
    }
    
    public func prepareRestore(action: @escaping () -> Void) {
        self.restoreAction = action
    }
    
    public func onPIPWillBegin(action: @escaping () -> Void) {
        self.pipWillStart = action
    }
    
    public func onPIPDidBegin(action: @escaping () -> Void) {
        self.pipDidStart = action
    }
    
    public func onPIPWillEnd(action: @escaping () -> Void) {
        self.pipWillEnd = action
    }
    
    
    public func onPIPDidEnd(action: @escaping () -> Void) {
        self.pipDidEnd = action
    }
    
    public func setupPictureInPicture(layer: AVPlayerLayer) {
        // Ensure PiP is supported by current device.
        if AVPictureInPictureController.isPictureInPictureSupported() {
            // Create a new controller, passing the reference to the AVPlayerLayer.
            self.pipController = AVPictureInPictureController(playerLayer: layer)
            self.pipController?.delegate = self
            self.playStateUpdateWatcher()
        } else {
            
        }
    }
    
    private func playStateUpdateWatcher() {
        self.pipPossibleObservation = self.pipController?.observe(\AVPictureInPictureController.isPictureInPicturePossible, options: [.initial, .new]) { [weak self] _, change in
            self?.stateUpdate(change.newValue ?? false)
        }
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        self.restoreAction()
        completionHandler(true)
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        self.pipFailed(error)
    }
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.pipWillStart()
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.pipDidStart()
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.pipWillEnd()
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.pipDidEnd()
    }
}

public class PlayerUIView: UIView, ObservableObject {
    public let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper? = nil
    private var timer: DispatchSourceTimer? = nil
    private var videoCanPlay: (Bool) -> Void = {_ in}
    private var videoComplete: () -> Void = {}
    private var finishObserver: Any? = nil
    public var pipController: PIPController? = nil
    
    @Published fileprivate var videoUpdate: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.player = AVQueuePlayer()
        self.layer.addSublayer(self.playerLayer)
    }
    
    func cacheAsset(url: URL) -> AVAsset {
        if url.isFileURL {
            return AVAsset(url: url)
        }
        let fm = FileManager.default
        do {
            let cacheKey = url.lastPathComponent
            let cacheFolder = try fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let cacheURL = cacheFolder.appendingPathComponent(cacheKey)
            if fm.fileExists(atPath: cacheURL.path) {
                return AVAsset(url: cacheURL)
            } else {
                DispatchQueue.global(qos: .utility).async {
                    do {
                        let data = try Data(contentsOf: url)
                        try data.write(to: cacheURL)
                    } catch {
                        print(error)
                    }
                }
                return AVAsset(url: url)
            }
        } catch {
            print(error)
            return AVAsset(url: url)
        }
    }
    
    public func setupPIP() {
        self.pipController = PIPController(layer: self.playerLayer)
    }
    
    public func mute() {
        self.playerLayer.player?.isMuted = true
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
    
    public func updateVideo(url: URL, setCategory: AVAudioSession.Category = .playback, options: AVAudioSession.CategoryOptions) {
        let asset = self.cacheAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        DispatchQueue.main.async {
            self.playerLooper = nil
            self.observePlayerItem(item: item)
            self.playerLayer.player?.replaceCurrentItem(with: item)
            do {
                try AVAudioSession.sharedInstance().setCategory(setCategory, options: options)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch(let error) {
                print("audio error: \(error.localizedDescription)")
            }
        }
        self.notifyViewUpdate()
    }
    
    public func loopVideo(url: URL, setCategory: AVAudioSession.Category = .playback, options: AVAudioSession.CategoryOptions) {
        let asset = self.cacheAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        DispatchQueue.main.async {
            self.playerLayer.player?.replaceCurrentItem(with: item)
            do {
                try AVAudioSession.sharedInstance().setCategory(setCategory, options: options)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch(let error) {
                print("audio error: \(error.localizedDescription)")
            }
            if (self.playerLayer.player as? AVQueuePlayer) != nil {
                self.playerLooper = AVPlayerLooper(player: self.playerLayer.player as! AVQueuePlayer, templateItem: item)
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
