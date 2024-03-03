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
    
    var location: CLLocation?

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
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                    var resourceType = PHAssetResourceType.photo
                    if  ( resolvedSettings.deferredPhotoProxyDimensions.width > 0 ) && ( resolvedSettings.deferredPhotoProxyDimensions.height > 0 ) {
                        resourceType = PHAssetResourceType.photoProxy
                    }
                    creationRequest.addResource(with: resourceType, data: self.photoData!, options: options)
                    creationRequest.location = self.location
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                    self.completionHandler(self)
                })
            } else {
                self.completionHandler(self)
            }
        }
    }
}

