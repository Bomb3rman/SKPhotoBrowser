//
//  SKVideoPlayer.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-09-12.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import Foundation
import AVFoundation

protocol SKVideoPlayerDelegate {
    func playerCurrentTimeDidChange(elapsedTime: Float64, videoPlayer: SKVideoPlayer)
    func playerPlaybackDidEnd(videoPlayer: SKVideoPlayer)
}

class SKVideoPlayer {
    
    var delegate: SKVideoPlayerDelegate?
    
    var frame: CGRect! {
        didSet {
            self.playerLayer.frame = frame
        }
    }
    
    private var asset: AVURLAsset!
    private var duration: Float64!
    private var playerItem: AVPlayerItem!
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var timeObserver: AnyObject!
    
    init(URL: NSURL) {
        asset = AVURLAsset(URL: URL)
        duration = CMTimeGetSeconds(asset.duration)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .Pause
        playerLayer = AVPlayerLayer(player: player)
        
        
        self.timeObserver = self.player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue()) { [weak self] (elapsedTime: CMTime) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.observeTime(elapsedTime)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
    }
        
    deinit {
        player.pause()
        player.removeTimeObserver(timeObserver)
    
        playerLayer.removeFromSuperlayer()
    
        delegate = nil
    
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
        
    func layer() -> CALayer {
        return playerLayer
    }
    
    func play() {
        player.play()
    }
        
    func pause() {
        player.pause()
    }
        
    func isPlaying() -> Bool {
        return player.rate > 0
    }
    
    @objc func playerItemDidPlayToEndTime() {
        player.seekToTime(kCMTimeZero, completionHandler: { (finished: Bool) in
            self.player.pause()
            self.delegate?.playerPlaybackDidEnd(self)
        })
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(player.currentItem!.duration)
        if duration.isFinite {
            delegate?.playerCurrentTimeDidChange(CMTimeGetSeconds(elapsedTime), videoPlayer: self)
        }
    }
}
