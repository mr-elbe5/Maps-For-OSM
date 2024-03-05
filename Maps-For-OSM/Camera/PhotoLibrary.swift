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
    
    static func savePhoto(photoData: Data, fileType: AVFileType?, location: CLLocation?, resultHandler: @escaping (Bool) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = fileType?.rawValue ?? defaultFileType.rawValue
                    let resourceType = PHAssetResourceType.photo
                    creationRequest.addResource(with: resourceType, data: photoData, options: options)
                    creationRequest.location = location
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error. occurred while saving photo to photo library: \(error)")
                    }
                    DispatchQueue.main.async{
                        resultHandler(true)
                    }
                })
            } else {
                resultHandler(false)
            }
        }
    }
    
    static func saveVideo(outputFileURL: URL, location: CLLocation?, resultHandler: @escaping (Bool) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    creationRequest.location = location
                }, completionHandler: { success, error in
                    if let error = error {
                        print("Error. occurred while saving video to photo library: \(error)")
                    }
                    resultHandler(true)
                })
            } else {
                resultHandler(false)
            }
        }
    }
    
}
