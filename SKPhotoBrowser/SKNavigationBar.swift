//
//  SKNavigationBar.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-09-09.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

class SKNavigationBar: UINavigationBar {

    fileprivate weak var browser: SKPhotoBrowser?
    fileprivate var navigationItem: UINavigationItem!
    fileprivate var videoScrubber: SKVideoScrubber!
    
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
    
    func updateTitle(_ currentPageIndex: Int) {
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
    
    func updateScrubber(_ progress: Float, currentTime: Float) {
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
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        clipsToBounds = true
        isTranslucent = true
        setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.white ]
    }
    
    func setupCloseButton() {
        if SKPhotoBrowserOptions.displayCloseButton {
            guard let browser = self.browser else {
                return
            }
            
            navigationItem.leftBarButtonItem = SKBackButton(target: browser, action: #selector(SKPhotoBrowser.closeButtonPressed))
        }
    }
    
    func frameForVideoScrubber() -> CGRect {
        return CGRect(x: 55, y: bounds.height/2, width: bounds.size.width - 80, height: 20)
    }
}

class SKBackButton: UIBarButtonItem {
    
    init(target: Any?, action: Selector?) {
        super.init()
        
        let backImageView = UIImageView(frame: CGRect(x: -15, y: 0, width: 15, height: 15))
        backImageView.clipsToBounds = true
        backImageView.layer.masksToBounds = true
        backImageView.contentMode = .scaleAspectFit
        backImageView.tintColor = .white
        backImageView.image = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_back_wh",
                                      in: Bundle(for: SKPhotoBrowser.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        
        let backLabel = UILabel()
        backLabel.text = "Back"
        backLabel.textColor = .white
        backLabel.font = UIFont.systemFont(ofSize: 15)
        backLabel.sizeToFit()
        backLabel.frame.origin.x = backImageView.frame.origin.x + backImageView.frame.width + 3
        backLabel.center.y = backImageView.center.y
        
        let backButton = UIView(frame: backLabel.frame)
        backButton.addSubview(backImageView)
        backButton.addSubview(backLabel)
        
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        backButton.addGestureRecognizer(tapGesture)
        
        customView = backButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
