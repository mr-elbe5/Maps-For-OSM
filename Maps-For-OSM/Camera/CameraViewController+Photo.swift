/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos

extension CameraViewController{
    
    func configurePhotoOutput() {
        let supportedMaxPhotoDimensions = self.currentDevice.activeFormat.supportedMaxPhotoDimensions
        let largestDimension = supportedMaxPhotoDimensions.last
        self.photoOutput.maxPhotoDimensions = largestDimension!
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
            photoCaptureProcessor.location = self.locationManager.location
            photoCaptureProcessor.delegate = self
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            self.photoOutputReadinessCoordinator.stopTrackingCaptureRequest(using: photoSettings.uniqueID)
        }
    }
    
}

extension CameraViewController: PhotoCaptureProcessorDelegate{
    
    func photoCaptured(data: Data?) {
        DispatchQueue.main.async{
            if let data = data, let image = UIImage(data: data){
                let imageFile = ImageFile()
                imageFile.saveImage(uiImage: image)
                if let location = LocationService.shared.location{
                    self.assertLocation(coordinate: location.coordinate){ location in
                        let changeState = location.media.isEmpty
                        location.addMedia(file: imageFile)
                        LocationPool.save()
                        if changeState{
                            self.delegate?.markersChanged()
                        }
                    }
                }
            }
        }
    }
    
}

protocol PhotoCaptureProcessorDelegate{
    func photoCaptured(data: Data?)
}

class PhotoCaptureProcessor: NSObject {
    
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    lazy var context = CIContext()
    
    private let completionHandler: (PhotoCaptureProcessor) -> Void
    private var photoData: Data?
    
    var location: CLLocation?
    
    var delegate: PhotoCaptureProcessorDelegate? = nil

    init(with requestedPhotoSettings: AVCapturePhotoSettings, completionHandler: @escaping (PhotoCaptureProcessor) -> Void) {
        self.requestedPhotoSettings = requestedPhotoSettings
        self.completionHandler = completionHandler
    }
    
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        self.photoData = photo.fileDataRepresentation()
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
        PhotoLibrary.savePhoto(photoData: self.photoData!, fileType: self.requestedPhotoSettings.processedFileType, location: self.location, resultHandler: { success in
            self.completionHandler(self)
        })
        self.delegate?.photoCaptured(data: self.photoData)
    }
}

