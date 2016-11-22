//
//  PHAsset+Fetch.swift
//  SKPhotoBrowser
//
//  Created by Omair Baskanderi on 2016-11-22.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    
    static func fetchAssetWithLocalIdentifier(_ identifier: String, options: PHFetchOptions?) -> PHAsset? {
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: options).lastObject {
            return asset
        }
        
        var result: PHAsset?
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: options)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format:"localIdentifier ==[cd] %@", identifier)
        
        userAlbums.enumerateObjects({
            (objectCollection : AnyObject, _ : Int, stopCollectionEnumeration : UnsafeMutablePointer<ObjCBool>) in
            
            guard let collection = objectCollection as? PHAssetCollection else {
                return
            }
            
            let assetsFetchResult = PHAsset.fetchAssets(in: collection, options:fetchOptions)
            
            assetsFetchResult.enumerateObjects({
                (objectAsset : AnyObject, _ : Int, stopAssetEnumeration: UnsafeMutablePointer<ObjCBool>) in
                
                guard let asset = objectAsset as? PHAsset else {
                    return
                }
                
                result = asset
                stopAssetEnumeration.initialize(to: true)
                stopCollectionEnumeration.initialize(to: true)
            })
        })
        
        return result
    }
}
