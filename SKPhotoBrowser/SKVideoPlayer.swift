//
//  SKVideoPlayer.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-09-12.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import Foundation
import AVFoundation

protocol SKVideoPlayerDelegate: class {
    func playerCurrentTimeDidChange(progress: Float, currentTime: Float, videoPlayer: SKVideoPlayer)
    func playerPlaybackDidEnd(videoPlayer: SKVideoPlayer)
    func playerStarted(videoPlayer: SKVideoPlayer)
    func playerPaused(videoPlayer: SKVideoPlayer)
}

class SKVideoPlayer {
    
    weak var delegate: SKVideoPlayerDelegate?
    
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
    private var isSeekInProgress = false
    private var chaseTime = kCMTimeZero
    
    init(URL: NSURL) {
        asset = AVURLAsset(URL: URL)
        duration = CMTimeGetSeconds(asset.duration)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .Pause
        playerLayer = AVPlayerLayer(player: player)
        
        self.timeObserver = self.player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 10), queue: dispatch_get_main_queue()) { [weak self] (elapsedTime: CMTime) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.observeTime(elapsedTime)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(scrubberStart), name: SKVideoScrubber.Start, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(scrubberEnd), name: SKVideoScrubber.End, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(scrubberValueChanged), name: SKVideoScrubber.ValueChanged, object: nil)
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
    
    @objc func play() {
        player.play()
        delegate?.playerStarted(self)
    }
        
    func pause() {
        player.pause()
        delegate?.playerPaused(self)
    }
    
    func reset() {
        self.player.pause()
        player.seekToTime(kCMTimeZero, completionHandler: { (finished: Bool) in })
    }
        
    func isPlaying() -> Bool {
        guard let player = self.player else {
            return false
        }
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
            let currentTime  = CMTimeGetSeconds(player.currentTime())
            let progress = currentTime/duration
            delegate?.playerCurrentTimeDidChange(Float(progress), currentTime: Float(CMTimeGetSeconds(elapsedTime)), videoPlayer: self)
        }
    }
}

// MARK: Handle Scrubbing Notifications

private extension SKVideoPlayer {
    
    @objc func scrubberStart() {
        self.pause()
    }
    
    @objc func scrubberEnd() {
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(play), userInfo: nil, repeats: false)
    }
    
    @objc func scrubberValueChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo, value = userInfo[SKVideoScrubber.ValueKey] as? Float {
            let seconds = duration * Float64(value)
            let seekToTime = CMTimeMake(Int64(seconds), 1)
            stopPlayingAndSeekSmoothlyToTime(seekToTime)
        }
    }
}

private extension SKVideoPlayer {
    func stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime) {
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime;
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        }
    }
    
    func trySeekToChaseTime() {
        if player.status == .Unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
        } else if player.status == .ReadyToPlay {
            actuallySeekToTime()
        }
    }
    
    func actuallySeekToTime() {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        player.seekToTime(seekTimeInProgress, toleranceBefore: kCMTimeZero,
                          toleranceAfter: kCMTimeZero, completionHandler:
            { (isFinished:Bool) -> Void in
                
                if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                    self.isSeekInProgress = false
                } else {
                    self.trySeekToChaseTime()
                }
        })
    }
}
