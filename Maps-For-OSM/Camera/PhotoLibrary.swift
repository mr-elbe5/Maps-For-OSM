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
                })
            } else {
                resultHandler("")
            }
        }
    }
    
    static func fetchAsset(localIdentifier: String, resultHandler: @escaping (PHAsset?) -> Void){
        PHPhotoLibrary.requestAuthorization(for: .readWrite){ status in
            if status == .authorized {
                let options = PHFetchOptions()
                options.includeHiddenAssets = false
                options.predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)") // Only images
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: options)
                if assets.count == 1{
                    resultHandler(assets[0])
                    return
                }
                resultHandler(nil)
            }
        }
    }
    
    static func getFile(localIdentifier: String, resultHandler: @escaping (Data?) -> Void){
        PHPhotoLibrary.requestAuthorization(for: .readWrite){ status in
            if status == .authorized {
                print("get file authorized")
                PhotoLibrary.fetchAsset(localIdentifier: localIdentifier){ asset in
                    if let asset = asset{
                        print("got asset")
                        asset.requestContentEditingInput(with: nil, completionHandler:{ editingInput, hashables in
                                if let url = editingInput?.fullSizeImageURL{
                                    print("url = \(url)")
                                    let data = FileController.readFile(url: url)
                                    print("data size = \(data?.count ?? 0)")
                                    resultHandler(data)
                                    return
                                }
                            })
                    }
                }
            }
        }
        resultHandler(nil)
    }
    
}
