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
    
    func addControls(){
        
        captureModeControl.insertSegment(with: UIImage(systemName: "camera"), at: 0, animated: false)
        captureModeControl.insertSegment(with: UIImage(systemName: "video"), at: 1, animated: false)
        captureModeControl.selectedSegmentIndex = 0
        captureModeControl.addTarget(self, action: #selector(toggleCaptureMode), for: .valueChanged)
        captureModeControl.backgroundColor = .systemGray
        bodyView.addSubview(captureModeControl)
        captureModeControl.setAnchors(top: bodyView.topAnchor, leading: bodyView.leadingAnchor, insets: defaultInsets)
        
        hdrVideoModeButton.setup(icon: "square.3.layers.3d.down.right.slash")
        hdrVideoModeButton.addTarget(self, action: #selector(toggleHDRVideoMode), for: .touchDown)
        bodyView.addSubview(hdrVideoModeButton)
        hdrVideoModeButton.setAnchors(top: bodyView.topAnchor, leading: captureModeControl.trailingAnchor, insets: defaultInsets)
        
        flashModeButton.setup(icon: "bolt.badge.automatic")
        flashModeButton.addTarget(self, action: #selector(toggleFlashMode), for: .touchDown)
        bodyView.addSubview(flashModeButton)
        flashModeButton.setAnchors(top: bodyView.topAnchor, leading: hdrVideoModeButton.trailingAnchor, insets: defaultInsets)
        
        closeButton.setImage(UIImage(systemName: "x.circle"), for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchDown)
        bodyView.addSubview(closeButton)
        closeButton.setAnchors(top: bodyView.topAnchor, trailing: bodyView.trailingAnchor, insets: defaultInsets)
        
        let infoButton = CameraIconButton()
        infoButton.setup(icon: "info.circle")
        infoButton.addTarget(self, action: #selector(openInfo), for: .touchDown)
        bodyView.addSubview(infoButton)
        infoButton.setAnchors(top: bodyView.topAnchor, trailing: closeButton.leadingAnchor, insets: defaultInsets)
        
        zoomLabel.textColor = .white
        bodyView.addSubview(zoomLabel)
        zoomLabel.setAnchors(top: captureModeControl.bottomAnchor, leading: bodyView.leadingAnchor, insets: defaultInsets)
        
        if backDevices.count > 1{
            for i in 0..<backDevices.count{
                var lensFactor = "1x"
                let device = backDevices[i]
                switch device.deviceType{
                case .builtInUltraWideCamera:
                    lensFactor = "0.5x"
                case .builtInTelephotoCamera:
                    lensFactor = "2x"
                default:
                    lensFactor = "1x"
                }
                backLensControl.insertSegment(withTitle: lensFactor, at: i, animated: false)
            }
            backLensControl.selectedSegmentIndex = 0
            backLensControl.addTarget(self, action: #selector(changeBackLens), for: .valueChanged)
            bodyView.addSubview(backLensControl)
            backLensControl.backgroundColor = .systemGray
            backLensControl.setAnchors(leading: bodyView.leadingAnchor, bottom: bodyView.bottomAnchor, insets: defaultInsets)
        }
        
        captureButton.addTarget(self, action: #selector(capture), for: .touchDown)
        bodyView.addSubview(captureButton)
        captureButton.setAnchors()
            .centerX(bodyView.centerXAnchor)
            .bottom(bodyView.bottomAnchor,inset: -defaultInset)
            .width(60)
            .height(60)
        
        cameraButton.setup(icon: "arrow.triangle.2.circlepath.camera")
        cameraButton.addTarget(self, action: #selector(changeCamera), for: .touchDown)
        bodyView.addSubview(cameraButton)
        cameraButton.setAnchors(trailing: bodyView.trailingAnchor, bottom: bodyView.bottomAnchor, insets: defaultInsets)
        
        bodyView.addSubview(cameraUnavailableLabel)
        cameraUnavailableLabel.setAnchors()
            .centerX(bodyView.centerXAnchor)
            .centerY(bodyView.centerYAnchor)
        cameraUnavailableLabel.isHidden = true
        
        tapGestureRecognizer.addTarget(self, action: #selector(focusAndExposeTap))
        tapGestureRecognizer.isEnabled = true
        previewView.addGestureRecognizer(tapGestureRecognizer)
        
        pinchGestureRecognizer.addTarget(self, action: #selector(zoomTap))
        pinchGestureRecognizer.isEnabled = true
        previewView.addGestureRecognizer(pinchGestureRecognizer)
        
        updateFlashButton()
    }
    
    func enableControls(_ enable: Bool){
        //print("enable controls: \(enable)")
        backLensControl.isHidden = currentPosition == .front || !enable
        backLensControl.isEnabled = currentPosition == .back && enable
        cameraButton.isEnabled = enable
        captureButton.isEnabled = enable
        captureModeControl.isEnabled = enable
        hdrVideoModeButton.isEnabled = enable && !isPhotoMode
        hdrVideoModeButton.isHidden = !enable || isPhotoMode
    }
    
    func updateZoomLabel(){
        zoomLabel.text = "\(String(format: "%.1f", currentZoom))x"
    }
    
    func updateFlashButton(){
        switch flashMode{
        case .auto:
            flashModeButton.setImage(UIImage(systemName: "bolt.badge.automatic"), for: .normal)
        case .on:
            flashModeButton.setImage(UIImage(systemName: "bolt"), for: .normal)
        case .off:
            flashModeButton.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
        @unknown default:
            flashModeButton.setImage(UIImage(systemName: "bolt"), for: .normal)
        }
    }
    
    @objc func changeCamera() {
        enableControls(false)
        self.selectedMovieMode10BitDeviceFormat = nil
        var newVideoDevice: AVCaptureDevice? = nil
        switch currentPosition {
        case .unspecified, .front:
            newVideoDevice = backDevices[currentBackCameraIndex]
        case .back:
            newVideoDevice = frontDevice
        @unknown default:
            newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        }
        if let newVideoDevice = newVideoDevice{
            AVCaptureDevice.userPreferredCamera = newVideoDevice
            changeVideoDevice(newVideoDevice, completion: {
                DispatchQueue.main.async {
                    self.enableControls(true)
                }
            })
        }
        else{
            print("Could not change camera")
            DispatchQueue.main.async {
                self.enableControls(true)
            }
        }
    }
    
    @objc func changeBackLens() {
        if currentPosition != .back{
            print("back lens cannot change when front lens is active")
            return
        }
        currentBackCameraIndex = backLensControl.selectedSegmentIndex
        enableControls(false)
        self.selectedMovieMode10BitDeviceFormat = nil
        let newVideoDevice = backDevices[currentBackCameraIndex]
        AVCaptureDevice.userPreferredCamera = newVideoDevice
        self.changeVideoDevice(newVideoDevice, completion: {
            DispatchQueue.main.async {
                self.enableControls(true)
            }
        })
    }
    
    @objc func focusAndExposeTap() {
        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapGestureRecognizer.location(in: tapGestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    @objc func zoomTap() {
        switch pinchGestureRecognizer.state{
        case .began: 
            currentZoomAtBegin = currentZoom
        case .ended:
            currentZoomAtBegin = 1.0
        case .changed:
            currentZoom = pinchGestureRecognizer.scale * currentZoomAtBegin
            currentZoom = min(max(1.0, currentZoom), currentMaxZoom)
            do{
                try currentDevice.lockForConfiguration()
                currentDevice.videoZoomFactor = currentZoom
                currentDevice.unlockForConfiguration()
                updateZoomLabel()
            }
            catch (let err){
                print(err.localizedDescription)
            }
        default:
            break
        }
    }
    
    @objc func capture() {
        if isPhotoMode{
            capturePhoto()
        }
        else{
            toggleMovieRecording()
        }
    }
    
    @objc func toggleHDRVideoMode() {
        if isPhotoMode{
            print("use hdr only in video mode")
            return
        }
        sessionQueue.async {
            self.isHdrVideoMode = !self.isHdrVideoMode
            DispatchQueue.main.async {
                if self.isHdrVideoMode {
                    do {
                        try self.currentDevice.lockForConfiguration()
                        self.currentDevice.activeFormat = self.selectedMovieMode10BitDeviceFormat!
                        self.currentDevice.unlockForConfiguration()
                    } catch {
                        print("Could not lock device for configuration: \(error)")
                    }
                    self.hdrVideoModeButton.setImage(UIImage(systemName: "square.3.layers.3d.down.right"),for: .normal)
                } else {
                    self.session.beginConfiguration()
                    self.session.sessionPreset = .high
                    self.session.commitConfiguration()
                    self.hdrVideoModeButton.setImage(UIImage(systemName: "square.3.layers.3d.down.right.slash"),for: .normal)
                }
            }
        }
    }
    
    @objc func toggleFlashMode(){
        switch flashMode{
        case .auto:
            flashMode = .off
        case .off:
            flashMode = .on
        case .on:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
        photoSettings.flashMode = flashMode
        updateFlashButton()
    }
    
    @objc func openInfo(){
        let controller = CameraInfoViewController()
        self.present(controller, animated: false)
    }
    
    @objc func close(){
        self.dismiss(animated: true)
    }
    
    @objc func toggleCaptureMode() {
        isPhotoMode = !isPhotoMode
        //print("isPhotoMode = \(cameraSettings.isPhotoMode)")
        enableControls(false)
        if isPhotoMode {
            print("running photo mode")
            enableControls(false)
            selectedMovieMode10BitDeviceFormat = nil
            sessionQueue.async {
                self.session.beginConfiguration()
                self.session.removeOutput(self.movieFileOutput!)
                self.session.sessionPreset = .photo
                self.movieFileOutput = nil
                self.configurePhotoOutput()
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.enableControls(true)
                    self.updateZoomLabel()
                }
            }
        } else {
            print("running video mode")
            sessionQueue.async {
                let movieFileOutput = AVCaptureMovieFileOutput()
                if self.session.canAddOutput(movieFileOutput) {
                    self.session.beginConfiguration()
                    self.session.addOutput(movieFileOutput)
                    self.session.sessionPreset = .high
                    self.selectedMovieMode10BitDeviceFormat = self.tenBitVariantOfFormat(activeFormat: self.currentDevice.activeFormat)
                    if self.selectedMovieMode10BitDeviceFormat != nil {
                        DispatchQueue.main.async {
                            self.hdrVideoModeButton.isHidden = false
                            self.hdrVideoModeButton.isEnabled = true
                        }
                        if self.isHdrVideoMode {
                            do {
                                try self.currentDevice.lockForConfiguration()
                                self.currentDevice.activeFormat = self.selectedMovieMode10BitDeviceFormat!
                                print("Setting 'x420' format \(String(describing: self.selectedMovieMode10BitDeviceFormat)) for video recording")
                                self.currentDevice.unlockForConfiguration()
                            } catch {
                                print("Could not lock device for configuration: \(error)")
                            }
                        }
                    }
                    if let connection = movieFileOutput.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.session.commitConfiguration()
                    self.movieFileOutput = movieFileOutput
                    DispatchQueue.main.async {
                        self.enableControls(true)
                        self.updateZoomLabel()
                    }
                }
            }
        }
    }
    
}
