//
//  SKZoomingScrollView.swift
//  SKViewExample
//
//  Created by suzuki_keihsi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import AVFoundation

open class SKZoomingScrollView: UIScrollView {
    var captionView: SKCaptionView!
    var photo: SKPhotoProtocol! {
        didSet {
            photoImageView.image = nil
            if photo != nil {
                displayImage(complete: false)
                photo.delegate = self
            }
        }
    }
    var displayPlaybackControls = false
    
    fileprivate(set) var photoImageView: SKDetectingImageView!
    fileprivate weak var photoBrowser: SKPhotoBrowser?
    fileprivate var tapView: SKDetectingView!
    fileprivate var indicatorView: SKIndicatorView!
    fileprivate var videoPlayer: SKVideoPlayer!
    fileprivate var playButton: UIButton!
    fileprivate var downloadButton: SKDownloadButton!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        photoBrowser = browser
        setup()
    }
    
    deinit {
        photoBrowser = nil
        videoPlayer = nil
        playButton = nil
        downloadButton = nil
    }
    
    func setup() {
        // tap
        tapView = SKDetectingView(frame: bounds)
        tapView.delegate = self
        tapView.backgroundColor = .clear
        tapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(tapView)
        
        // image
        photoImageView = SKDetectingImageView(frame: frame)
        photoImageView.delegate = self
        photoImageView.contentMode = .bottom
        photoImageView.backgroundColor = .clear
        addSubview(photoImageView)
        
        // indicator
        indicatorView = SKIndicatorView(frame: frame)
        addSubview(indicatorView)
        
        // self
        backgroundColor = .clear
        delegate = self
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrubberStart), name: NSNotification.Name(rawValue: SKVideoScrubber.Start), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playVideo), name: NSNotification.Name(rawValue: SKPHOTO_PLAY_VIDEO_NOTIFICATION), object: nil)
    }
    
    func viewWillAppear() {
        if let videoPlayer = videoPlayer {
            videoPlayer.reset()
        }
        displayPlaybackControls = false
        
        if let playButton = playButton {
            playButton.isHidden = false
            bringSubview(toFront: playButton)
        }
        
        if let downloadButton = downloadButton {
            downloadButton.isHidden = false
            bringSubview(toFront: downloadButton)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playVideo), name: NSNotification.Name(rawValue: SKPHOTO_PLAY_VIDEO_NOTIFICATION), object: nil)
    }
    
    func viewWillDisapper() {
        if let videoPlayer = videoPlayer {
            videoPlayer.reset()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SKPHOTO_PLAY_VIDEO_NOTIFICATION), object: nil)
    }
    
    func displayingVideo() -> Bool {
        return photo.videoURL != nil
    }
    
    func videoDuration() -> Float64 {
        if !displayingVideo() {
            return 0
        }
        let asset = AVURLAsset(url: photo.videoURL as URL)
        return CMTimeGetSeconds(asset.duration)
    }
    
    func isPlayingVideo() -> Bool {
        guard let videoPlayer = videoPlayer else {
            return false
        }
        return videoPlayer.isPlaying()
    }
    
    func isPausedVideo() -> Bool {
        guard let videoPlayer = videoPlayer else {
            return false
        }
        return !videoPlayer.isPlaying()
    }
    
    func playVideo() {
        if photo.videoURL == nil {
            return
        }
        
        if videoPlayer == nil {
            initVideoPlayer()
        }
        
        guard let videoPlayer = self.videoPlayer else {
            return
        }
        
        if let button = playButton {
            button.isHidden = true
        }
        
        displayPlaybackControls = true
        
        if !videoPlayer.isPlaying() {
            videoPlayer.play()
        }
        photoBrowser?.toolbar.updateButtons()
    }
    
    func pauseVideo() {
        guard let videoPlayer = videoPlayer else {
            return
        }
        videoPlayer.pause()
        photoBrowser?.toolbar.updateButtons()
    }
    
    // MARK: - override
    
    open override func layoutSubviews() {
        tapView.frame = bounds
        indicatorView.frame = bounds
        
        super.layoutSubviews()
        
        let boundsSize = bounds.size
        var frameToCenter = photoImageView.frame
        
        // horizon
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2)
        } else {
            frameToCenter.origin.x = 0
        }
        // vertical
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if !photoImageView.frame.equalTo(frameToCenter) {
            photoImageView.frame = frameToCenter
        }
        
        // Video Player
        if let videoPlayer = self.videoPlayer {
            videoPlayer.frame = self.bounds
        }
        
        // Play Button
        if let playButton = self.playButton {
            playButton.center = CGPoint(x: frame.width/2, y: frame.height/2)
        }
        
        if let downloadButton = self.downloadButton {
            downloadButton.center = CGPoint(x: frame.width/2, y: frame.height/2)
        }
    }
    
    open func setMaxMinZoomScalesForCurrentBounds() {
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        guard let photoImageView = photoImageView else {
            return
        }
        
        let boundsSize = bounds.size
        let imageSize = photoImageView.frame.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale: CGFloat = min(xScale, yScale)
        var maxScale: CGFloat = 1.0
        
        let scale = max(UIScreen.main.scale, 2.0)
        let deviceScreenWidth = UIScreen.main.bounds.width * scale // width in pixels. scale needs to remove if to use the old algorithm
        let deviceScreenHeight = UIScreen.main.bounds.height * scale // height in pixels. scale needs to remove if to use the old algorithm
        
        if photoImageView.frame.width < deviceScreenWidth {
            // I think that we should to get coefficient between device screen width and image width and assign it to maxScale. I made two mode that we will get the same result for different device orientations.
            if UIApplication.shared.statusBarOrientation.isPortrait {
                maxScale = deviceScreenHeight / photoImageView.frame.width
            } else {
                maxScale = deviceScreenWidth / photoImageView.frame.width
            }
        } else if photoImageView.frame.width > deviceScreenWidth {
            maxScale = 1.0
        } else {
            // here if photoImageView.frame.width == deviceScreenWidth
            maxScale = 2.5
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        zoomScale = minScale
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5
        // After changing this value, we still never use more
        /*
         maxScale = maxScale / scale
         if maxScale < minScale {
         maxScale = minScale * 2
         }
         */
        
        // reset position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.height)
        
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.isScrollEnabled = false
        
        // If it's a video then disable zooming
        if displayingVideo() {
            self.maximumZoomScale = self.zoomScale;
            self.minimumZoomScale = self.zoomScale;
        }
        
        setNeedsLayout()
    }
    
    open func prepareForReuse() {
        photo.delegate = nil
        photo = nil
        
        if videoPlayer != nil {
            videoPlayer.pause()
            videoPlayer = nil
        }
        
        if playButton != nil {
            playButton.removeFromSuperview()
            playButton = nil
        }
        
        if downloadButton != nil {
            downloadButton.removeFromSuperview()
            downloadButton = nil
        }
    }
    
    // MARK: - image
    open func displayImage(complete flag: Bool) {
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        contentSize = CGSize.zero
        
        if !flag {
            if photo.underlyingImage == nil {
                indicatorView.startAnimating()
            }
            photo.loadUnderlyingImageAndNotify()
        } else {
            indicatorView.stopAnimating()
        }
        
        if let image = photo.underlyingImage {
            /*
             // create padding
             let width: CGFloat = image.size.width + SKPhotoBrowserOptions.imagePaddingX
             let height: CGFloat = image.size.height + SKPhotoBrowserOptions.imagePaddingY;
             UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, 0.0);
             let context: CGContextRef = UIGraphicsGetCurrentContext()!;
             UIGraphicsPushContext(context);
             let origin: CGPoint = CGPointMake((width - image.size.width) / 2, (height - image.size.height) / 2);
             image.drawAtPoint(origin)
             UIGraphicsPopContext();
             let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             */
            
            // image
            photoImageView.image = image
            photoImageView.contentMode = photo.contentMode
            photoImageView.backgroundColor = SKPhotoBrowserOptions.backgroundColor
            
            var photoImageViewFrame = CGRect.zero
            photoImageViewFrame.origin = CGPoint.zero
            photoImageViewFrame.size = image.size
            
            photoImageView.frame = photoImageViewFrame
            
            contentSize = photoImageViewFrame.size
            
            setMaxMinZoomScalesForCurrentBounds()
            
            if photo.enableDownload && downloadButton == nil {
                downloadButton = SKDownloadButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
                downloadButton.delegate = self
                if photo.isDownloading {
                    downloadButton.setProgress(photo.downloadProgress, animated: false)
                }
                addSubview(downloadButton)
            } else if !photo.enableDownload && displayingVideo() && playButton == nil {
                playButton = UIButton(type: .custom)
                playButton.setImage(UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_play_blk", in: Bundle(for: SKPhotoBrowser.self), compatibleWith: nil), for: UIControlState())
                playButton.setImage(UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_play_tap_blk", in: Bundle(for: SKPhotoBrowser.self), compatibleWith: nil), for: .highlighted)
                playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
                playButton.sizeToFit()
                playButton.isUserInteractionEnabled = true
                playButton.isHidden = isPlayingVideo()
                addSubview(playButton)
            }
            
            if !photo.enableDownload && downloadButton != nil {
                downloadButton.removeFromSuperview()
                downloadButton = nil
            }
        }
        setNeedsLayout()
    }
    
    open func displayImageFailure() {
        indicatorView.stopAnimating()
    }
    
    // MARK: - handle tap
    
    open func handleDoubleTap(_ touchPoint: CGPoint) {
        if let photoBrowser = photoBrowser {
            NSObject.cancelPreviousPerformRequests(withTarget: photoBrowser)
        }
        
        if zoomScale > minimumZoomScale {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // zoom in
            // I think that the result should be the same after double touch or pinch
            /* var newZoom: CGFloat = zoomScale * 3.13
             if newZoom >= maximumZoomScale {
             newZoom = maximumZoomScale
             }
             */
            let zoomRect = zoomRectForScrollViewWith(maximumZoomScale, touchPoint: touchPoint)
            zoom(to: zoomRect, animated: true)
        }
        
        // delay control
        photoBrowser?.hideControlsAfterDelay()
    }
}

// MARK: - UIScrollViewDelegate

extension SKZoomingScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.isScrollEnabled = true
        photoBrowser?.cancelControlHiding()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - SKDetectingImageViewDelegate

extension SKZoomingScrollView: SKDetectingViewDelegate {
    func handleSingleTap(_ view: UIView, touch: UITouch) {
        guard let browser = photoBrowser else {
            return
        }
        guard SKPhotoBrowserOptions.enableZoomBlackArea == true else {
            return
        }
        
        if browser.areControlsHidden() == false && SKPhotoBrowserOptions.enableSingleTapDismiss == true {
            browser.determineAndClose()
        } else {
            browser.toggleControls()
        }
    }
    
    func handleDoubleTap(_ view: UIView, touch: UITouch) {
        if SKPhotoBrowserOptions.enableZoomBlackArea == true {
            let needPoint = getViewFramePercent(view, touch: touch)
            handleDoubleTap(needPoint)
        }
    }
}

// MARK: - SKDetectingImageViewDelegate

extension SKZoomingScrollView: SKDetectingImageViewDelegate {
    func handleImageViewSingleTap(_ touchPoint: CGPoint) {
        guard let browser = photoBrowser else {
            return
        }
        if SKPhotoBrowserOptions.enableSingleTapDismiss {
            browser.determineAndClose()
        } else {
            browser.toggleControls()
        }
    }
    
    func handleImageViewDoubleTap(_ touchPoint: CGPoint) {
        if displayingVideo() {
            return
        }
        handleDoubleTap(touchPoint)
    }
}

extension SKZoomingScrollView: SKVideoPlayerDelegate {
    func playerCurrentTimeDidChange(_ progress: Float, currentTime: Float, videoPlayer: SKVideoPlayer) {
        photoBrowser?.navigationBar.updateScrubber(progress, currentTime: currentTime)
    }
    
    func playerPlaybackDidEnd(_ videoPlayer: SKVideoPlayer) {
        playButton.isHidden = false
        photoBrowser?.toolbar.updateButtons()
    }
    
    func playerStarted(_ videoPlayer: SKVideoPlayer) {
        playVideo()
    }
    
    func playerPaused(_ videoPlayer: SKVideoPlayer) {
        photoBrowser?.toolbar.updateButtons()
    }
}

private extension SKZoomingScrollView {
    func getViewFramePercent(_ view: UIView, touch: UITouch) -> CGPoint {
        let oneWidthViewPercent = view.bounds.width / 100
        let viewTouchPoint = touch.location(in: view)
        let viewWidthTouch = viewTouchPoint.x
        let viewPercentTouch = viewWidthTouch / oneWidthViewPercent
        
        let photoWidth = photoImageView.bounds.width
        let onePhotoPercent = photoWidth / 100
        let needPoint = viewPercentTouch * onePhotoPercent
        
        var Y: CGFloat!
        
        if viewTouchPoint.y < view.bounds.height / 2 {
            Y = 0
        } else {
            Y = photoImageView.bounds.height
        }
        let allPoint = CGPoint(x: needPoint, y: Y)
        return allPoint
    }
    
    func zoomRectForScrollViewWith(_ scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = frame.size.width / scale
        let h = frame.size.height / scale
        let x = touchPoint.x - (h / max(UIScreen.main.scale, 2.0))
        let y = touchPoint.y - (w / max(UIScreen.main.scale, 2.0))
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func initVideoPlayer() {
        guard let photo = self.photo else {
            return
        }
        
        videoPlayer = SKVideoPlayer(URL: photo.videoURL)
        videoPlayer.frame = self.bounds
        videoPlayer.delegate = self
        layer.addSublayer(videoPlayer.layer())
    }
}

private extension SKZoomingScrollView {
    
    @objc func scrubberStart() {
        if videoPlayer == nil {
            initVideoPlayer()
        }
    }
}

extension SKZoomingScrollView: SKPhotoDownloadDelegate {
    
    public func progress(value: CGFloat) {
        guard let downloadButton = self.downloadButton else {
            return
        }
        
        if photo.isDownloading {
            downloadButton.setProgress(value)
        }
    }
    
    public func downloadFinished() {
        displayImage(complete: true)
    }
}

extension SKZoomingScrollView: SKDownloadButtonDelegate {
    public func cancelPressed() {
        photoBrowser?.delegate?.cancelDownloadPhoto?(photoBrowser!, index: photo.index)
    }
    
    public func downloadPressed() {
        photoBrowser?.delegate?.downloadPhoto?(photoBrowser!, index: photo.index)
    }
}
