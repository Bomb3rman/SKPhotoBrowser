//
//  SKCaptionView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi  on 2015/10/07.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

public class SKCaptionView: UIView {
    
    private var titleLabel: UILabel!
    private var detailLabel: UILabel!
    
    var titleText: String! {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    var detailText: String! {
        didSet {
            detailLabel.text = detailText
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 10, height: 20))
        titleLabel.textAlignment = .Center
        titleLabel.backgroundColor = .clearColor()
        titleLabel.font  = UIFont.boldSystemFontOfSize(15)
        titleLabel.textColor = .whiteColor()
        titleLabel.text = nil
        addSubview(titleLabel)
        
        detailLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.size.height, width: frame.width - 10, height: 16))
        detailLabel.textAlignment = .Center
        detailLabel.backgroundColor = .clearColor()
        detailLabel.font  = UIFont.systemFontOfSize(12)
        detailLabel.textColor = .whiteColor()
        detailLabel.text = nil
        addSubview(detailLabel)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            let width = (frame.width - 10) / 2
            titleLabel.frame = CGRect(x: 0, y: 3, width: width, height: 16)
            titleLabel.textAlignment = .Right
            
            let x = titleLabel.frame.origin.x + titleLabel.frame.width + 15
            detailLabel.frame = CGRect(x: x, y: 3, width: width - 15, height: 16)
            detailLabel.textAlignment = .Left
        } else {
            titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width - 10, height: 16)
            titleLabel.textAlignment = .Center
            
            detailLabel.frame = CGRect(x: 0, y: titleLabel.frame.size.height + 4, width: frame.width - 10, height: 16)
            detailLabel.textAlignment = .Center
        }
    }
}
