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
    func playerCurrentTimeDidChange(_ progress: Float, currentTime: Float, videoPlayer: SKVideoPlayer)
    func playerPlaybackDidEnd(_ videoPlayer: SKVideoPlayer)
    func playerStarted(_ videoPlayer: SKVideoPlayer)
    func playerPaused(_ videoPlayer: SKVideoPlayer)
}

class SKVideoPlayer {
    
    weak var delegate: SKVideoPlayerDelegate?
    
    var frame: CGRect! {
        didSet {
            self.playerLayer.frame = frame
        }
    }
    var isActive = true
    
    fileprivate var asset: AVURLAsset!
    fileprivate var duration: Float64!
    fileprivate var playerItem: AVPlayerItem!
    fileprivate var player: AVPlayer!
    fileprivate var playerLayer: AVPlayerLayer!
    fileprivate var timeObserver: AnyObject!
    fileprivate var isSeekInProgress = false
    fileprivate var chaseTime = kCMTimeZero
    
    init(URL: Foundation.URL) {
        asset = AVURLAsset(url: URL)
        duration = CMTimeGetSeconds(asset.duration)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .pause
        playerLayer = AVPlayerLayer(player: player)
        
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 10), queue: DispatchQueue.main) { [weak self] (elapsedTime: CMTime) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.observeTime(elapsedTime)
        } as AnyObject!
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(scrubberStart), name: NSNotification.Name(rawValue: SKVideoScrubber.Start), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrubberEnd), name: NSNotification.Name(rawValue: SKVideoScrubber.End), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrubberValueChanged), name: NSNotification.Name(rawValue: SKVideoScrubber.ValueChanged), object: nil)
    }
        
    deinit {
        player.pause()
        player.removeTimeObserver(timeObserver)
    
        playerLayer.removeFromSuperlayer()
    
        delegate = nil
    
        NotificationCenter.default.removeObserver(self)
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
        isActive = true
        self.player.pause()
        player.seek(to: kCMTimeZero, completionHandler: { (finished: Bool) in })
    }
        
    func isPlaying() -> Bool {
        guard let player = self.player else {
            return false
        }
        return player.rate > 0
    }
    
    @objc func playerItemDidPlayToEndTime() {
        player.seek(to: kCMTimeZero, completionHandler: { (finished: Bool) in
            self.player.pause()
            self.delegate?.playerPlaybackDidEnd(self)
        })
    }
    
    fileprivate func observeTime(_ elapsedTime: CMTime) {
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
        if isActive {
            self.pause()
        }
    }
    
    @objc func scrubberEnd() {
        if isActive {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(play), userInfo: nil, repeats: false)
        }
    }
    
    @objc func scrubberValueChanged(_ notification: Notification) {
        if isActive {
            if let userInfo = (notification as NSNotification).userInfo, let value = userInfo[SKVideoScrubber.ValueKey] as? Float {
                let seconds = duration * Float64(value)
                let seekToTime = CMTimeMake(Int64(seconds), 1)
                stopPlayingAndSeekSmoothlyToTime(seekToTime)
            }
        }
    }
}

private extension SKVideoPlayer {
    func stopPlayingAndSeekSmoothlyToTime(_ newChaseTime: CMTime) {
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime;
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        }
    }
    
    func trySeekToChaseTime() {
        if player.status == .unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
        } else if player.status == .readyToPlay {
            actuallySeekToTime()
        }
    }
    
    func actuallySeekToTime() {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        player.seek(to: seekTimeInProgress, toleranceBefore: kCMTimeZero,
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
