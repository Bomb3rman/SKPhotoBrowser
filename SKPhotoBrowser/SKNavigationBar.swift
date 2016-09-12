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
    }
    
    func updateTitle(currentPageIndex: Int) {
        guard let browser = browser else { return }
        
        if browser.numberOfPhotos > 1 {
            navigationItem.title = "\(currentPageIndex + 1) / \(browser.numberOfPhotos)"
        } else {
            navigationItem.title = nil
        }
    }
}

private extension SKNavigationBar {
    
    func setupAppearence() {
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)//UIColor.blackColor().withAlphaComponent(0.6)
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
}
