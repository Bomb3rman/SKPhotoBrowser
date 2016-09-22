//
//  ViewController.swift
//  SKPhotoBrowserExample
//
//  Created by suzuki_keishi on 2015/10/06.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class FromLocalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SKPhotoBrowserDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [SKPhotoProtocol]()
    var downloadTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTestData()
        setupCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func updateDownloadProgress(timer: Timer) {
        if let index = timer.userInfo as? Int, let photo = images[index] as? SKLocalPhoto {
            photo.downloadProgress = photo.downloadProgress + 0.1
            
            if photo.downloadProgress >= 1.0 {
                downloadTimer.invalidate()
            }
        }
    }
}


 // MARK: - UICollectionViewDataSource
extension FromLocalViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exampleCollectionViewCell", for: indexPath) as? ExampleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if (indexPath as NSIndexPath).row < 10 {
            cell.exampleImageView.image = UIImage(named: "image\((indexPath as NSIndexPath).row % 10).jpg")
        } else {
            let path = Bundle.main.path(forResource: "video\((indexPath as NSIndexPath).row%10)", ofType:"mov")
            let videoThumb = SKPhoto.videoThumb(URL(fileURLWithPath: path!, isDirectory: false))
            cell.exampleImageView.image = videoThumb
        }
//        cell.exampleImageView.contentMode = .ScaleAspectFill
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension FromLocalViewController {
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell else {
            return
        }
        guard let originImage = cell.exampleImageView.image else {
            return
        }
        
//        SKPhotoBrowserOptions.displayToolbar = false
        
        let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell)
        browser.initializePageIndex((indexPath as NSIndexPath).row)
        browser.delegate = self
//        browser.updateCloseButton(UIImage(named: "image1.jpg")!)
        
        present(browser, animated: true, completion: {})
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 300)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 200)
        }
    }
}


// MARK: - SKPhotoBrowserDelegate

extension FromLocalViewController {
    func didShowPhotoAtIndex(_ index: Int) {
        collectionView.visibleCells.forEach({$0.isHidden = false})
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = true
    }
    
    func willDismissAtPageIndex(_ index: Int) {
        collectionView.visibleCells.forEach({$0.isHidden = false})
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = true
    }
    
    func willShowActionSheet(_ photoIndex: Int) {
        // do some handle if you need
    }
    
    func didDismissAtPageIndex(_ index: Int) {
        collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.isHidden = false
    }
    
    func didDismissActionSheetWithButtonIndex(_ buttonIndex: Int, photoIndex: Int) {
        // handle dismissing custom actions
    }
    
    func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: (() -> Void)) {
        reload()
    }
    
    func viewForPhoto(_ browser: SKPhotoBrowser, index: Int) -> UIView? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    func downloadPhoto(_ browser: SKPhotoBrowser, index: Int) {
        images[index].isDownloading = true
        downloadTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateDownloadProgress), userInfo: index, repeats: true)
    }
    
    func cancelDownloadPhoto(_ browser: SKPhotoBrowser, index: Int) {
        images[index].isDownloading = false
        if downloadTimer != nil {
            downloadTimer.invalidate()
            downloadTimer = nil
        }
    }
}

// MARK: - private

private extension FromLocalViewController {
    func setupTestData() {
        images = createLocalPhotos()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createLocalPhotos() -> [SKPhotoProtocol] {
        return (0..<12).map { (i: Int) -> SKPhotoProtocol in
            var photo: SKLocalPhoto!
            if i < 10 {
                let url = Bundle.main.path(forResource: "image\(i%10)", ofType:"jpg")
                photo = SKLocalPhoto.photoWithImageURL(url!)
                photo.enableDownload = (i == 1)
            } else {
                let path = Bundle.main.path(forResource: "video\(i%10)", ofType:"mov")
                photo = SKLocalPhoto.photoWithVideoURL(URL(fileURLWithPath: path!, isDirectory: false), holderURL: nil)
            }
            photo.captionTitle = captionTitle[i%10]
            photo.captionDetail = captionDetail[i%10]
            return photo
        }
    }
}

class ExampleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var exampleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        exampleImageView.image = nil
        layer.cornerRadius = 25.0
        layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        exampleImageView.image = nil
    }
}


var captionTitle = ["Lucas Nogueira",
                    "Bruno Caboclo",
                    "Demar Derozen",
                    "Kyle Lowry",
                    "Patrick Patteron",
                    "Cory Joseph",
                    "Jonas Valanciunas",
                    "DeMarre Carroll",
                    "Terrence Ross",
                    "Norman Powell",
                    "Delon Wright",
                    "Jared Sullinger"]

var captionDetail = ["01-30-2016 10:10pm",
                     "Today 12:35pm",
                     "Monday 1:00am",
                     "Tuesday 6:00pm",
                     "Wednesday 1:23pm",
                     "Thursday 8:09am",
                     "Friday 12:00am",
                     "Saturday 3:30pm",
                     "Sunday 11:59pm",
                     "Yesterday 10:30am",
                     "October 31, 2017",
                     "December 25, 2004 12:00am"]
