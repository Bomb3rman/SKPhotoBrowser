//
//  SKLocalPhoto.swift
//  SKPhotoBrowser
//
//  Created by Antoine Barrault on 13/04/2016.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit
import Photos

// MARK: - SKLocalPhoto
open class SKLocalPhoto: NSObject, SKPhotoProtocol {
    
    static let ImageManager = PHImageManager.default()
    
    open var underlyingImage: UIImage!
    
    open var photoURL: String! {
        didSet {
            if photoURL != nil {
                // Fetch Image
                if FileManager.default.fileExists(atPath: photoURL) {
                    if let data = FileManager.default.contents(atPath: photoURL), let image = UIImage(data: data) {
                        self.underlyingImage = image
                        self.loadUnderlyingImageComplete()
                    }
                } else {
                    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photoURL], options: nil)
                    if let asset = assets.firstObject {
                        SKLocalPhoto.ImageManager.requestImage(for: asset, targetSize: UIScreen.main.bounds.size, contentMode: .aspectFill, options: nil, resultHandler: { (result: UIImage?, info: [AnyHashable : Any]?) in
                            self.underlyingImage = result
                            self.loadUnderlyingImageComplete()
                        })
                    }
                }
            }
        }
    }
    
    open var contentMode: UIViewContentMode = .scaleToFill
    open var shouldCachePhotoURLImage: Bool = false
    open var captionTitle: String!
    open var captionDetail: String!
    open var index: Int = 0
    open var videoURL: URL!
    open var enableDownload: Bool = false
    open var isDownloading: Bool = false
    weak open var delegate: SKPhotoDownloadDelegate!
    
    open var downloadProgress: CGFloat = 0.0 {
        didSet {
            guard let delegate = delegate else {
                return
            }
            delegate.progress(value: downloadProgress)
            
            if downloadProgress >= 1.0 {
                enableDownload = false
                delegate.downloadFinished()
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    convenience init(url: String, holder: UIImage?) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    convenience init(videoURL: URL, holderURL: URL?) {
        self.init()
        self.videoURL = videoURL
        
        if holderURL != nil {
            underlyingImage = UIImage(contentsOfFile: holderURL!.path)
        } else {
            underlyingImage = SKPhoto.videoThumb(videoURL)
        }
    }
    
    convenience init(localIdentifier: String) {
        self.init()
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: PHFetchOptions()).firstObject {
            let videoOption = PHVideoRequestOptions()
            videoOption.version = .original
            videoOption.deliveryMode = .fastFormat
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOption, resultHandler: { (avasset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
                if let urlAsset = avasset as? AVURLAsset {
                    self.videoURL = urlAsset.url
                    self.underlyingImage = SKPhoto.videoThumb(self.videoURL)
                    self.loadUnderlyingImageComplete()
                }
            })
        }
    }
    
    open func checkCache() {}
    
    open func loadUnderlyingImageAndNotify() {
        
        if underlyingImage != nil && photoURL == nil {
            loadUnderlyingImageComplete()
        }
        
        if photoURL != nil {
            // Fetch Image
            // If photoURL is file path load image from filesystem
            // else maybe the photoURL is asset local identifier, attempt to load from PHImageManager
            if FileManager.default.fileExists(atPath: photoURL) {
                if let data = FileManager.default.contents(atPath: photoURL) {
                    if let image = UIImage(data: data) {
                        self.underlyingImage = image
                        self.loadUnderlyingImageComplete()
                    }
                }
            } else {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photoURL], options: nil)
                if let asset = assets.firstObject {
                    SKLocalPhoto.ImageManager.requestImage(for: asset, targetSize: UIScreen.main.bounds.size, contentMode: .aspectFill, options: nil, resultHandler: { (result: UIImage?, info: [AnyHashable : Any]?) in
                        self.underlyingImage = result
                        self.loadUnderlyingImageComplete()
                    })
                }
            }
        }
    }
    
    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
    // MARK: - class func
    open class func photoWithImageURL(_ url: String) -> SKLocalPhoto {
        return SKLocalPhoto(url: url)
    }
    
    open class func photoWithImageURL(_ url: String, holder: UIImage?) -> SKLocalPhoto {
        return SKLocalPhoto(url: url, holder: holder)
    }
    
    open class func photoWithVideoIdentifier(_ localIdentifier: String) -> SKLocalPhoto {
        return SKLocalPhoto(localIdentifier: localIdentifier)
    }
    
    open class func photoWithVideoURL(_ videoURL: URL, holderURL: URL?) -> SKLocalPhoto {
        return SKLocalPhoto(videoURL: videoURL, holderURL: holderURL)
    }
}
