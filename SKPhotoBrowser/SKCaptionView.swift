//
//  SKCaptionView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi  on 2015/10/07.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

open class SKCaptionView: UIView {
    
    fileprivate var titleLabel: UILabel!
    fileprivate var detailLabel: UILabel!
    
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
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        titleLabel.font  = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        titleLabel.text = nil
        addSubview(titleLabel)
        
        detailLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.size.height, width: frame.width - 10, height: 16))
        detailLabel.textAlignment = .center
        detailLabel.backgroundColor = .clear
        detailLabel.font  = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = .white
        detailLabel.text = nil
        addSubview(detailLabel)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsLandscape(currentOrientation) {
            let width = (frame.width - 10) / 2
            titleLabel.frame = CGRect(x: 0, y: 3, width: width, height: 16)
            titleLabel.textAlignment = .right
            
            let x = titleLabel.frame.origin.x + titleLabel.frame.width + 15
            detailLabel.frame = CGRect(x: x, y: 3, width: width - 15, height: 16)
            detailLabel.textAlignment = .left
        } else {
            titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width - 10, height: 16)
            titleLabel.textAlignment = .center
            
            detailLabel.frame = CGRect(x: 0, y: titleLabel.frame.size.height + 4, width: frame.width - 10, height: 16)
            detailLabel.textAlignment = .center
        }
    }
}
