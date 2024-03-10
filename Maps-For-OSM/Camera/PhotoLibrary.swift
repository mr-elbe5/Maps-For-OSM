/*
 E5Cam
 Simple Camera
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
    
}
