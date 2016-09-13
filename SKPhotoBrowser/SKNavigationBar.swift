//
//  SKNavigationBar.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-09-09.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

class SKNavigationBar: UINavigationBar {

    private weak var browser: SKPhotoBrowser?
    private var navigationItem: UINavigationItem!
    private var videoScrubber: SKVideoScrubber!
    
    var closeButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser
        
        navigationItem = UINavigationItem()
        items = [navigationItem]
        
        setupAppearence()
        setupCloseButton()
        videoScrubber = SKVideoScrubber(frame: frameForVideoScrubber())
    }
    
    func updateTitle(currentPageIndex: Int) {
        guard let browser = browser else { return }
        
        func showCounterTitle() {
            if SKPhotoBrowserOptions.displayCounterLabel {
                navigationItem.titleView = nil
                if browser.numberOfPhotos > 1 {
                    navigationItem.title = "\(currentPageIndex + 1) / \(browser.numberOfPhotos)"
                } else {
                    navigationItem.title = nil
                }
            }
        }
        
        if let page = browser.pageDisplayedAtIndex(currentPageIndex) {
            if page.displayingVideo() {
                videoScrubber.duration = Float(page.videoDuration())
                videoScrubber.frame = frameForVideoScrubber()
                
                navigationItem.titleView = videoScrubber
                navigationItem.title = nil
            } else {
                showCounterTitle()
            }
        } else {
            showCounterTitle()
        }
    }
    
    func updateScrubber(progress: Float, currentTime: Float) {
        videoScrubber.progress = progress
        videoScrubber.currentTime = currentTime
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        navigationItem.titleView?.frame = frameForVideoScrubber()
    }
}

private extension SKNavigationBar {
    
    func setupAppearence() {
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        clipsToBounds = true
        translucent = true
        setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
    }
    
    func setupCloseButton() {
        if SKPhotoBrowserOptions.displayCloseButton {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: browser, action: #selector(SKPhotoBrowser.closeButtonPressed))
            closeButton.tintColor = .whiteColor()
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    func frameForVideoScrubber() -> CGRect {
        return CGRect(x: 55, y: bounds.height/2, width: bounds.size.width - 80, height: 20)
    }
}
