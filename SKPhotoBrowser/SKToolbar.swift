//
//  SKToolbar.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/12.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

// helpers which often used
private let bundle = NSBundle(forClass: SKPhotoBrowser.self)

class SKToolbar: UIToolbar {
    var toolCaptionView: SKCaptionView!
    var toolCaptionButton: UIBarButtonItem!
    var toolPreviousButton: UIBarButtonItem!
    var toolNextButton: UIBarButtonItem!
    var toolActionButton: UIBarButtonItem!
    var toolDeleteButton: UIBarButtonItem!
    var toolPlayButton: UIBarButtonItem!
    var toolPauseButton: UIBarButtonItem!
    
    private weak var browser: SKPhotoBrowser?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser
        
        setupApperance()
        setupPreviousButton()
        setupNextButton()
        setupCaptionButton()
        setupActionButton()
        setupDeleteButton()
        setupPlayButton()
        setupPauseButton()
        setupToolbar()
    }
    
    func updateToolbar(currentPageIndex: Int) {
        guard let browser = browser else { return }
        
        let photo = browser.photoAtIndex(currentPageIndex)
        
        if let captionTitle = photo.captionTitle {
            toolCaptionView.titleText = captionTitle
        }
        
        if let captionDetail = photo.captionDetail {
            toolCaptionView.detailText = captionDetail
        }
        
        toolPreviousButton.enabled = (currentPageIndex > 0)
        toolNextButton.enabled = (currentPageIndex < browser.numberOfPhotos - 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        toolCaptionButton.customView?.frame.size = sizeForCaptionViewAtOrientation()
    }
    
    func updateButtons() {
        setupToolbar()
    }
}

private extension SKToolbar {
    func setupApperance() {
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        clipsToBounds = true
        translucent = true
        setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        
        // toolbar
        if !SKPhotoBrowserOptions.displayToolbar {
            hidden = true
        }
    }
    
    func setupToolbar() {
        guard let browser = browser else { return }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()

        if SKPhotoBrowserOptions.displayAction && SKPhotoBrowserOptions.displayDeleteButton {
            items.append(toolActionButton)
        }
        
        items.append(flexSpace)
        
        func showCaption() {
            if browser.numberOfPhotos > 1 && SKPhotoBrowserOptions.displayBackAndForwardButton {
                items.append(toolPreviousButton)
            }
            
            items.append(flexSpace)
            items.append(toolCaptionButton)
            items.append(flexSpace)
            
            if browser.numberOfPhotos > 1 && SKPhotoBrowserOptions.displayBackAndForwardButton {
                items.append(toolNextButton)
            }
        }
        
        if let page = browser.pageDisplayedAtIndex(browser.currentPageIndex) {
            if page.isPlayingVideo() {
                items.append(toolPauseButton)
            } else if page.isPausedVideo() {
                items.append(toolPlayButton)
            } else {
                showCaption()
            }
        } else {
            showCaption()
        }
        
        items.append(flexSpace)
        
        if SKPhotoBrowserOptions.displayDeleteButton {
            items.append(toolDeleteButton)
        } else if SKPhotoBrowserOptions.displayAction {
            items.append(toolActionButton)
        }
        
        setItems(items, animated: false)
    }
    
    func setupPreviousButton() {
        let previousBtn = SKPreviousButton(frame: frame)
        previousBtn.addTarget(browser, action: #selector(SKPhotoBrowser.gotoPreviousPage), forControlEvents: .TouchUpInside)
        toolPreviousButton = UIBarButtonItem(customView: previousBtn)
    }
    
    func setupNextButton() {
        let nextBtn = SKNextButton(frame: frame)
        nextBtn.addTarget(browser, action: #selector(SKPhotoBrowser.gotoNextPage), forControlEvents: .TouchUpInside)
        toolNextButton = UIBarButtonItem(customView: nextBtn)
    }
    
    func setupCaptionButton() {
        toolCaptionView = SKCaptionView(frame: CGRectZero)
        toolCaptionButton = UIBarButtonItem(customView: toolCaptionView)
    }
    
    func setupActionButton() {
        toolActionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: browser, action: #selector(SKPhotoBrowser.actionButtonPressed))
        toolActionButton.tintColor = SKPhotoBrowserOptions.textAndIconColor
    }
    
    func setupDeleteButton() {
        toolDeleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: browser, action: #selector(SKPhotoBrowser.deleteButtonPressed))
        toolDeleteButton.tintColor = .whiteColor()
    }
    
    func setupPlayButton() {
        toolPlayButton = UIBarButtonItem(barButtonSystemItem: .Play, target: browser, action: #selector(SKPhotoBrowser.playButtonPressed))
        toolPlayButton.tintColor = .whiteColor()
    }
    
    func setupPauseButton() {
        toolPauseButton = UIBarButtonItem(barButtonSystemItem: .Pause, target: browser, action: #selector(SKPhotoBrowser.pauseButtonPressed))
        toolPauseButton.tintColor = .whiteColor()
    }
    
    func sizeForCaptionViewAtOrientation() -> CGSize {
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        var height: CGFloat = 38
        var width = bounds.size.width - (2 * 90)
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            height = 26
            width = bounds.size.width - (2 * 120)
        }
        return CGSize(width: width, height: height)
    }
}


class SKToolbarButton: UIButton {
    let insets: UIEdgeInsets = UIEdgeInsets(top: 13.25, left: 17.25, bottom: 13.25, right: 17.25)
    
    func setup(imageName: String) {
        backgroundColor = .clearColor()
        tintColor = SKPhotoBrowserOptions.textAndIconColor
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        contentMode = .Center
        
        let image = UIImage(named: "SKPhotoBrowser.bundle/images/\(imageName)",
                            inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate) ?? UIImage()
        setImage(image, forState: .Normal)
    }
}

class SKPreviousButton: SKToolbarButton {
    let imageName = "btn_common_back_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}

class SKNextButton: SKToolbarButton {
    let imageName = "btn_common_forward_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}
