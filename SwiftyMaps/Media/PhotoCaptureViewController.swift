/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVFoundation
import Photos


protocol PhotoCaptureDelegate{
    func photoCaptured(photo: ImageFile)
}

class PhotoCaptureViewController: CameraViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static var flashMode : AVCaptureDevice.FlashMode = .auto
    
    var delegate: PhotoCaptureDelegate? = nil
    
    private let photoOutput = AVCapturePhotoOutput()
    
    override func addCameraButtons(){
        
        cameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        cameraButton.addTarget(self, action: #selector(changeCamera), for: .touchDown)
        cameraButtonContainerView.addSubviewWithAnchors(cameraButton, top: cameraButtonContainerView.topAnchor, leading: cameraButtonContainerView.leadingAnchor, bottom: cameraButtonContainerView.bottomAnchor, insets: defaultInsets)
        
        flashButton.setImage(UIImage(systemName: "bolt.badge.a"), for: .normal)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchDown)
        cameraButtonContainerView.addSubviewWithAnchors(flashButton, top: cameraButtonContainerView.topAnchor, leading: cameraButton.trailingAnchor, trailing: cameraButtonContainerView.trailingAnchor, bottom: cameraButtonContainerView.bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: 2*defaultInset, bottom: defaultInset, right: defaultInset))
        
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchDown)
        bodyView.addSubviewWithAnchors(captureButton, bottom: bodyView.bottomAnchor, insets: defaultInsets)
            .centerX(bodyView.centerXAnchor)
            .width(50)
            .height(50)
        
    }
    
    override func enableCameraButtons(flag: Bool){
        captureButton.isEnabled = flag
        cameraButton.isEnabled = flag
    }
    
    func configurePhoto(){
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = false
            photoOutput.isDepthDataDeliveryEnabled = false
            photoOutput.isPortraitEffectsMatteDeliveryEnabled = false
            photoOutput.enabledSemanticSegmentationMatteTypes = []
            photoOutput.maxPhotoQualityPrioritization = .quality
            
        } else {
            error("PhotoCaptureViewController Could not add photo output to the session")
            isInputAvailable = false
            session.commitConfiguration()
            return
        }
    }
    
    override func configureSession(){
        isInputAvailable = true
        session.beginConfiguration()
        session.sessionPreset = .photo
        configureVideo()
        if !isInputAvailable{
            return
        }
        configurePhoto()
        if !isInputAvailable {
            return
        }
        session.commitConfiguration()
    }
    
    override func replaceVideoDevice(newVideoDevice videoDevice: AVCaptureDevice){
        let currentVideoDevice = self.videoDeviceInput.device
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            self.session.beginConfiguration()
            
            self.session.removeInput(self.videoDeviceInput)
            
            if self.session.canAddInput(videoDeviceInput) {
                NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                self.session.addInput(self.videoDeviceInput)
            }
            
            self.photoOutput.maxPhotoQualityPrioritization = .quality
            
            self.session.commitConfiguration()
            
        } catch let err{
            error("PhotoCaptureViewController Error occurred while creating video device input: \(err)")
        }
    }
    
    @objc func toggleFlash() {
        switch PhotoCaptureViewController.flashMode{
        case .auto:
            PhotoCaptureViewController.flashMode = .on
            self.flashButton.setImage(UIImage(systemName: "bolt"), for: .normal)
            break
        case .on:
            PhotoCaptureViewController.flashMode = .off
            self.flashButton.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
            break
        default:
            PhotoCaptureViewController.flashMode = .auto
            self.flashButton.setImage(UIImage(systemName: "bolt.badge.a"), for: .normal)
            break
        }
    }
    
    @objc func capturePhoto() {
        let videoPreviewLayerOrientation = preview.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            var photoSettings = AVCapturePhotoSettings()
            if  self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            }
            if self.videoDeviceInput.device.isFlashAvailable {
                //photoSettings.flashMode = self.flashMode
            }
            photoSettings.isHighResolutionPhotoEnabled = true
            
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            photoSettings.isDepthDataDeliveryEnabled = false
            photoSettings.photoQualityPrioritization = .quality
            photoSettings.flashMode = PhotoCaptureViewController.flashMode
            // shutter animation
            DispatchQueue.main.async {
                self.preview.videoPreviewLayer.opacity = 0
                UIView.animate(withDuration: 0.25) {
                    self.preview.videoPreviewLayer.opacity = 1
                }
            }
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            logError("PhotoCaptureViewController capturing photo", error: error)
        } else {
            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData){
                let acceptController = PhotoAcceptViewController(imageData: image)
                acceptController.delegate = self
                present(acceptController, animated: true)
            }
        }
    }
    
    override func addObservers(){
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.captureButton.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        super.addObservers()
    }
    
}

extension PhotoCaptureViewController: PhotoAcceptDelegate{
    
    func photoAccepted(imageData: UIImage, title: String) {
        debug("PhotoCaptureViewController photo accepted")
        let imageFile = ImageFile()
        imageFile.saveImage(uiImage: imageData)
        imageFile.title = title
        dismiss(animated: false){
            self.delegate?.photoCaptured(photo: imageFile)
        }
    }
    
    func photoDismissed() {
        debug("PhotoCaptureViewController photo dismissed")
    }
    
    
}

protocol PhotoAcceptDelegate{
    func photoAccepted(imageData: UIImage, title: String)
    func photoDismissed()
}

class PhotoAcceptViewController: UIViewController{
    
    var imageData : UIImage
    
    var titleField = UITextField()
    var saveButton = UIButton()
    var cancelButton = UIButton()
    
    var delegate: PhotoAcceptDelegate? = nil
    
    init(imageData: UIImage){
        self.imageData = imageData
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .black
        let imageView = UIImageView(image: imageData)
        imageView.setDefaults()
        imageView.setRoundedBorders()
        imageView.image = imageData
        imageView.setAspectRatioConstraint()
        view.addSubviewWithAnchors(imageView, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        view.addSubviewWithAnchors(titleField, top: imageView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        saveButton.setTitle("accept".localize(), for: .normal)
        saveButton.addTarget(self, action: #selector(accepted), for: .touchDown)
        view.addSubviewWithAnchors(saveButton, top: titleField.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
        cancelButton.setTitle("dismiss".localize(), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismissed), for: .touchDown)
        view.addSubviewWithAnchors(cancelButton, top: saveButton.bottomAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    @objc func accepted(){
        dismiss(animated: false){
            self.delegate?.photoAccepted(imageData: self.imageData, title: self.titleField.text!.trim())
        }
    }
    
    @objc func dismissed(){
        self .dismiss(animated: false){
            self.delegate?.photoDismissed()
        }
    }
    
}
