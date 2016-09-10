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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTestData()
        setupCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}


 // MARK: - UICollectionViewDataSource
extension FromLocalViewController {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("exampleCollectionViewCell", forIndexPath: indexPath) as? ExampleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.exampleImageView.image = UIImage(named: "image\(indexPath.row % 10).jpg")
//        cell.exampleImageView.contentMode = .ScaleAspectFill
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension FromLocalViewController {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ExampleCollectionViewCell else {
            return
        }
        guard let originImage = cell.exampleImageView.image else {
            return
        }
        
//        SKPhotoBrowserOptions.displayToolbar = false
        
        let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell)
        browser.initializePageIndex(indexPath.row)
        browser.delegate = self
//        browser.updateCloseButton(UIImage(named: "image1.jpg")!)
        
        presentViewController(browser, animated: true, completion: {})
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return CGSize(width: UIScreen.mainScreen().bounds.size.width / 2 - 5, height: 300)
        } else {
            return CGSize(width: UIScreen.mainScreen().bounds.size.width / 2 - 5, height: 200)
        }
    }
}


// MARK: - SKPhotoBrowserDelegate

extension FromLocalViewController {
    func didShowPhotoAtIndex(index: Int) {
        collectionView.visibleCells().forEach({$0.hidden = false})
        collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))?.hidden = true
    }
    
    func willDismissAtPageIndex(index: Int) {
        collectionView.visibleCells().forEach({$0.hidden = false})
        collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))?.hidden = true
    }
    
    func willShowActionSheet(photoIndex: Int) {
        // do some handle if you need
    }
    
    func didDismissAtPageIndex(index: Int) {
        collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))?.hidden = false
    }
    
    func didDismissActionSheetWithButtonIndex(buttonIndex: Int, photoIndex: Int) {
        // handle dismissing custom actions
    }
    
    func removePhoto(browser: SKPhotoBrowser, index: Int, reload: (() -> Void)) {
        reload()
    }
    
    func viewForPhoto(browser: SKPhotoBrowser, index: Int) -> UIView? {
        return collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))
    }
}

// MARK: - private

private extension FromLocalViewController {
    private func setupTestData() {
        images = createLocalPhotos()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createLocalPhotos() -> [SKPhotoProtocol] {
        return (0..<10).map { (i: Int) -> SKPhotoProtocol in
            let photo = SKPhoto.photoWithImage(UIImage(named: "image\(i%10).jpg")!)
            photo.captionTitle = captionTitle[i%10]
            photo.captionDetail = captionDetail[i%10]
//            photo.contentMode = .ScaleAspectFill
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
