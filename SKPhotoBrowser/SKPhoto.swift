//
//  SKPhoto.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import Photos

@objc public protocol SKPhotoDownloadDelegate {
    func progress(value: CGFloat)
    func downloadFinished()
}

@objc public protocol SKPhotoProtocol: NSObjectProtocol {
    var identifier: Int64 { get set }
    var underlyingImage: UIImage! { get }
    var captionTitle: String! { get }
    var captionDetail: String! { get }
    var index: Int { get set}
    var contentMode: UIViewContentMode { get set }
    var videoURL: URL! { get }
    var enableDownload: Bool { get set }
    var isDownloading: Bool {get set}
    var downloadProgress: CGFloat { get set }
    var autoPlayVideo: Bool { get }
    weak var delegate: SKPhotoDownloadDelegate! { get set }
    func loadUnderlyingImageAndNotify()
    func checkCache()
    func playVideo()
}

// MARK: - SKPhoto
open class SKPhoto: NSObject, SKPhotoProtocol {
    open var identifier: Int64 = 0 // not used by the photo browser can be used to identify photo by user
    public var autoPlayVideo: Bool = false
    open var underlyingImage: UIImage!
    open var photoURL: String!
    open var contentMode: UIViewContentMode = .scaleAspectFill
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
    
    convenience init(image: UIImage) {
        self.init()
        underlyingImage = image
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
    
    convenience init(videoURL: URL) {
        self.init()
        self.videoURL = videoURL
        underlyingImage = SKPhoto.videoThumb(videoURL)
    }
    
    open func checkCache() {
        guard let photoURL = photoURL else {
            return
        }
        guard shouldCachePhotoURLImage else {
            return
        }
        
        if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
            let request = URLRequest(url: URL(string: photoURL)!)
            if let img = SKCache.sharedCache.imageForRequest(request) {
                underlyingImage = img
            }
        } else {
            if let img = SKCache.sharedCache.imageForKey(photoURL) {
                underlyingImage = img
            }
        }
    }
    
    open func loadUnderlyingImageAndNotify() {
        
        if underlyingImage != nil {
            loadUnderlyingImageComplete()
            return
        }
        
        if photoURL != nil {
            // Fetch Image
            let session = URLSession(configuration: URLSessionConfiguration.default)
            if let nsURL = URL(string: photoURL) {
                var task: URLSessionDataTask!
                task = session.dataTask(with: nsURL, completionHandler: { [weak self](response: Data?, data: URLResponse?, error: NSError?) in
                    if let _self = self {
                        
                        if error != nil {
                            DispatchQueue.main.async {
                                _self.loadUnderlyingImageComplete()
                            }
                        }
                        
                        if let res = response, let image = UIImage(data: res) {
                            if _self.shouldCachePhotoURLImage {
                                if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
                                    SKCache.sharedCache.setImageData(response!, response: data!, request: task.originalRequest!)
                                } else {
                                    SKCache.sharedCache.setImage(image, forKey: _self.photoURL)
                                }
                            }
                            DispatchQueue.main.async {
                                _self.underlyingImage = image
                                _self.loadUnderlyingImageComplete()
                            }
                        }
                        session.finishTasksAndInvalidate()
                    }
                } as! (Data?, URLResponse?, Error?) -> Void)
                task.resume()
            }
        }
    }
    
    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
    open func playVideo() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_PLAY_VIDEO_NOTIFICATION), object: self)
    }
}

// MARK: - Static Function

extension SKPhoto {
    public static func photoWithImage(_ image: UIImage) -> SKPhoto {
        return SKPhoto(image: image)
    }
    
    public static func photoWithImageURL(_ url: String) -> SKPhoto {
        return SKPhoto(url: url)
    }
    
    public static func photoWithImageURL(_ url: String, holder: UIImage?) -> SKPhoto {
        return SKPhoto(url: url, holder: holder)
    }
    
    public static func photoWithVideoURL(_ videoURL: URL) -> SKPhoto {
        return SKPhoto(videoURL: videoURL)
    }
    
    public static func videoThumb(_ URL: Foundation.URL) -> UIImage? {
        let avasset = AVURLAsset(url: URL)
        let generator = AVAssetImageGenerator(asset: avasset)
        generator.appliesPreferredTrackTransform = true
        
        var time = avasset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    
}
