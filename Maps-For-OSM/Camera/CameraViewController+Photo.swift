/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos

extension CameraViewController{
    
    func configurePhotoOutput() {
        if !isCaptureEnabled{
            return
        }
        let supportedMaxPhotoDimensions = currentDevice.activeFormat.supportedMaxPhotoDimensions
        if let largestDimension = supportedMaxPhotoDimensions.last{
            self.photoOutput.maxPhotoDimensions = largestDimension
        }
        self.photoOutput.isLivePhotoCaptureEnabled = false
        self.photoOutput.maxPhotoQualityPrioritization = .quality
        self.photoOutput.isResponsiveCaptureEnabled = self.photoOutput.isResponsiveCaptureSupported
        self.photoOutput.isFastCapturePrioritizationEnabled = self.photoOutput.isFastCapturePrioritizationSupported
        self.photoOutput.isAutoDeferredPhotoDeliveryEnabled = false
        let photoSettings = self.setUpPhotoSettings()
        DispatchQueue.main.async {
            self.photoSettings = photoSettings
        }
    }
    
    func capturePhoto() {
        if !isCaptureEnabled{
            return
        }
        if self.photoSettings == nil {
            print("No photo settings to capture")
            return
        }
        let photoSettings = AVCapturePhotoSettings(from: self.photoSettings)
        self.photoOutputReadinessCoordinator.startTrackingCaptureRequest(using: photoSettings)
        let videoRotationAngle = self.videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelCapture
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoRotationAngle = videoRotationAngle
            }
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, completionHandler: { photoCaptureProcessor in
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            })
            photoCaptureProcessor.delegate = self.delegate
            photoCaptureProcessor.location = self.locationManager.location
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            self.photoOutputReadinessCoordinator.stopTrackingCaptureRequest(using: photoSettings.uniqueID)
        }
    }
    
}

class PhotoCaptureProcessor: NSObject {
    
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    lazy var context = CIContext()
    private let completionHandler: (PhotoCaptureProcessor) -> Void
    private var photoData: Data?
    
    var delegate: CameraDelegate? = nil
    var location: CLLocation?

    init(with requestedPhotoSettings: AVCapturePhotoSettings, completionHandler: @escaping (PhotoCaptureProcessor) -> Void) {
        self.requestedPhotoSettings = requestedPhotoSettings
        self.completionHandler = completionHandler
    }
    
}

class LocationCustomizer: NSObject, AVCapturePhotoFileDataRepresentationCustomizer{
    
    var location: CLLocation? = nil
    
    func replacementMetadata(for photo: AVCapturePhoto) -> [String : Any]?{
        let metadata = photo.metadata
        var map = [String : Any]()
        for key in metadata.keys{
            if let value = metadata[key]{
                map.updateValue(checkValue(key: key, value: value), forKey: key)
            }
        }
        map[kCGImagePropertyGPSDictionary as String] = getGPSValue()
        print(map)
        return map
    }
    
    func checkValue(key: String, value: Any) -> Any{
        if key == kCGImagePropertyExifDictionary as String, let location = location{
            if let subMap = value as? [String: Any]{
                var map = [String: Any]()
                for subKey in subMap.keys{
                    if let subValue = subMap[key]{
                        map.updateValue(subValue, forKey: subKey)
                    }
                    
                }
                map.updateValue(String(location.coordinate.latitude), forKey: kCGImagePropertyGPSLatitude as String)
                map.updateValue(String(location.coordinate.longitude), forKey: kCGImagePropertyGPSLongitude as String)
                map.updateValue(String(location.altitude), forKey: kCGImagePropertyGPSAltitude as String)
                print(map)
                return map
            }
        }
        return value
    }
    
    func getGPSValue() -> [String: Any]{
        var map = [String: Any]()
        if let location = location{
            map.updateValue(String(location.coordinate.latitude), forKey: kCGImagePropertyGPSLatitude as String)
            map.updateValue(String(location.coordinate.longitude), forKey: kCGImagePropertyGPSLongitude as String)
            map.updateValue(String(location.altitude), forKey: kCGImagePropertyGPSAltitude as String)
        }
        return map
    }
    
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        let customizer = LocationCustomizer()
        customizer.location = location
        self.photoData = photo.fileDataRepresentation(with: customizer)
        let exif = ExifData(data: photoData!)
        print(exif.toDictionary)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            completionHandler(self)
            return
        }
        guard photoData != nil else {
            print("No photo data resource")
            completionHandler(self)
            return
        }
        if let delegate = delegate{
            DispatchQueue.main.async{
                delegate.photoCaptured(data: self.photoData!)
            }
        }
        PhotoLibrary.savePhoto(photoData: self.photoData!, fileType: self.requestedPhotoSettings.processedFileType, location: self.location, resultHandler: { s in
            print("saved photo with locaIdentifier \(s)")
            self.completionHandler(self)
        })
    }
}

