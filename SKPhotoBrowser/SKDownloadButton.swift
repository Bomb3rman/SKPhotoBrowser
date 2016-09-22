//
//  SKDownloadButton.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-09-22.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import Foundation

public protocol SKDownloadButtonDelegate: class {
    func cancelPressed()
    func downloadPressed()
}

class SKDownloadButton: UIView {
    
    weak var delegate: SKDownloadButtonDelegate?
    
    fileprivate var downloadImageView: UIImageView!
    fileprivate var cancelImageView: UIImageView!
    fileprivate var target: AnyObject?
    fileprivate var selector: Selector?
    
    fileprivate var isShowingCancel: Bool = false {
        didSet {
            if isShowingCancel {
                downloadImageView.removeFromSuperview()
                addSubview(circularProgress)
                addSubview(cancelImageView)
            } else {
                circularProgress.removeFromSuperview()
                cancelImageView.removeFromSuperview()
                addSubview(downloadImageView)
            }
        }
    }
    lazy fileprivate var circularProgress: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.thicknessRatio = 0.1
        progress.enableIndeterminate()
        return progress
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        downloadImageView = UIImageView(frame: frame)
        downloadImageView.image = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_download_blk", in: Bundle(for: SKPhotoBrowser.self), compatibleWith: nil)
        downloadImageView.contentMode = .scaleAspectFit
        downloadImageView.backgroundColor = .white
        downloadImageView.clipsToBounds = true
        downloadImageView.layer.masksToBounds = true
        downloadImageView.layer.cornerRadius = downloadImageView.frame.width / 2.0
        downloadImageView.layer.borderColor = UIColor.clear.cgColor
        downloadImageView.layer.borderWidth = 0
        addSubview(downloadImageView)
        
        circularProgress.frame = frame
        
        cancelImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width - 10, height: frame.width - 10))
        cancelImageView.image = UIImage(named: "SKPhotoBrowser.bundle/images/btn_common_download_cancel_blk", in: Bundle(for: SKPhotoBrowser.self), compatibleWith: nil)
        cancelImageView.contentMode = .scaleAspectFit
        cancelImageView.backgroundColor = .white
        cancelImageView.clipsToBounds = true
        cancelImageView.layer.masksToBounds = true
        cancelImageView.layer.cornerRadius = cancelImageView.frame.width / 2.0
        cancelImageView.layer.borderColor = UIColor.clear.cgColor
        cancelImageView.layer.borderWidth = 0
        cancelImageView.center = circularProgress.center
        
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
        circularProgress.updateProgress(progress, animated: animated, duration: 1)
    }
}
