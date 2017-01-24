//
//  SKDownloadButton.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-09-22.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import Foundation
import MRProgress

public protocol SKDownloadButtonDelegate: class {
    func cancelPressed()
    func downloadPressed()
}

class SKDownloadButton: UIView {
    
    weak var delegate: SKDownloadButtonDelegate?
    
    fileprivate var downloadImageView: UIImageView!
    fileprivate var target: AnyObject?
    fileprivate var selector: Selector?
    
    fileprivate var isShowingCancel: Bool = false {
        didSet {
            if isShowingCancel {
                downloadImageView.removeFromSuperview()
                addSubview(circularProgress)
            } else {
                circularProgress.removeFromSuperview()
                addSubview(downloadImageView)
            }
        }
    }
    lazy fileprivate var circularProgress: MRCircularProgressView = {
        let progress = MRCircularProgressView()
        progress.tintColor = UIColor.white
        progress.mayStop = true
        progress.lineWidth = 3
        return progress
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        downloadImageView = UIImageView(frame: frame)
        downloadImageView.image = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_download_new_blk", in: Bundle(for: SKPhotoBrowser.self), compatibleWith: nil)
        downloadImageView.contentMode = .scaleAspectFit
        downloadImageView.backgroundColor = .white
        downloadImageView.clipsToBounds = true
        downloadImageView.layer.masksToBounds = true
        downloadImageView.layer.cornerRadius = downloadImageView.frame.width / 2.0
        addSubview(downloadImageView)
        
        circularProgress.frame = frame
        circularProgress.setProgress(0, animated: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed() {
        if isShowingCancel {
            delegate?.cancelPressed()
        } else {
            delegate?.downloadPressed()
        }
        isShowingCancel = !isShowingCancel
        
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        if progress > 0 && !isShowingCancel {
            isShowingCancel = true
        }
        
        if progress > 0 {
            circularProgress.setProgress(Float(progress), animated: animated)
        }
    }
}
