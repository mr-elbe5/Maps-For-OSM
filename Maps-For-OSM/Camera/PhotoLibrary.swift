/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos

class PhotoLibrary{
    
    static var defaultFileType: AVFileType = .jpg
    
    static var albumName = "MapsForOSM"
    
    static func savePhoto(photoData: Data, fileType: AVFileType?, location: CLLocation?, resultHandler: @escaping (String) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                var localIdentifier: String = ""
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = fileType?.rawValue ?? defaultFileType.rawValue
                    let resourceType = PHAssetResourceType.photo
                    creationRequest.addResource(with: resourceType, data: photoData, options: options)
                    creationRequest.location = location
                    localIdentifier = creationRequest.placeholderForCreatedAsset!.localIdentifier
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error. occurred while saving photo to photo library: \(error)")
                    }
                    DispatchQueue.main.async{
                        resultHandler(localIdentifier)
                        DispatchQueue.global(qos: .background).async {
                            PhotoLibrary.addToAlbum(localIdentifier: localIdentifier)
                        }
                    }
                })
            } else {
                resultHandler("")
            }
        }
    }
    
    static func saveVideo(outputFileURL: URL, location: CLLocation?, resultHandler: @escaping (String) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                var localIdentifier: String = ""
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    creationRequest.location = location
                    localIdentifier = creationRequest.placeholderForCreatedAsset!.localIdentifier
                }, completionHandler: { success, error in
                    if let error = error {
                        print("Error. occurred while saving video to photo library: \(error)")
                    }
                    resultHandler(localIdentifier)
                    DispatchQueue.global(qos: .background).async {
                        PhotoLibrary.addToAlbum(localIdentifier: localIdentifier)
                    }
                })
            } else {
                resultHandler("")
            }
        }
    }
    
    static func assertAlbum(resultHandler: @escaping(PHAssetCollection?) -> Void){
        if let assetCollection = fetchAssetCollectionForAlbum() {
            resultHandler(assetCollection)
            return
        }
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoLibrary.albumName)
                }) { success, error in
                    if success {
                        resultHandler(fetchAssetCollectionForAlbum())
                    } else {
                        print("Error \(String(describing: error))")
                        resultHandler(nil)
                    }
                }
            }
        }
    }
    
    static func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoLibrary.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    static func fetchAsset(localIdentifier: String) -> PHAsset?{
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if assets.count == 1{
            return assets[0]
        }
        return nil
    }
    
    static func addToAlbum(localIdentifier: String){
        print("adding \(localIdentifier) to album")
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.assertAlbum(){ album in
                    print("album is \(album.debugDescription)")
                    if let album = album, let asset = fetchAsset(localIdentifier: localIdentifier){
                        print("got it")
                        print(asset.localIdentifier)
                        PHPhotoLibrary.shared().performChanges({
                            let changeRequest = PHAssetCollectionChangeRequest(for: album)
                            changeRequest?.addAssets(PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil))
                        })
                        print("done")
                    }
                }
            }
        }
    }
    
}
