/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var bodyView = UIView()
    var cameraButtonView = UIView()
    var closeButtonView = UIView()
    var preview = CameraPreviewView()
    var cameraUnavailableLabel = UILabel()
    
    var session = AVCaptureSession()
    var isInputAvailable = false
    var isSessionRunning = false
    let sessionQueue = DispatchQueue(label: "camera session queue")
    
    var alertShown = false
    
    var keyValueObservations = [NSKeyValueObservation]()
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    var windowOrientation: UIInterfaceOrientation {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
    mediaType: .video, position: .unspecified)
    
    override func loadView() {
        super.loadView()
        view.addSubviewFillingSafeArea(bodyView)
        bodyView.backgroundColor = .black
        
        bodyView.addSubviewWithAnchors(closeButtonView, top: bodyView.topAnchor, trailing: bodyView.trailingAnchor)
            .setRoundedBorders(radius: 5)
            .setBackground(.black)
        let closeButton = UIButton().asIconButton("xmark.circle", color: .white)
        closeButtonView.addSubviewFilling(closeButton, insets: defaultInsets)
        closeButton.addTarget(self, action: #selector(close), for: .touchDown)
        
        bodyView.addSubviewWithAnchors(cameraButtonView, leading: bodyView.leadingAnchor, bottom: bodyView.bottomAnchor)
            .setRoundedBorders(radius: 5)
            .setBackground(.black)
        cameraButtonView.backgroundColor = .black
        
        addCameraButtons()
        
        bodyView.addSubviewFilling(preview, insets: .zero)
            .setBackground(.black)
        
        AVCaptureDevice.askCameraAuthorization(){ result in
            self.preview.session = self.session
            self.sessionQueue.async {
                self.configureSession()
            }
        }
        
    }
    
    func addCameraButtons(){
    }
    
    func enableCameraButtons(flag: Bool){
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isInputAvailable {
            sessionQueue.async {
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
        else{
            enableCameraButtons(flag: false)
            if !alertShown{
                showAlert(title: "camera".localize(), text: "cameraNotAvailable".localize())
                alertShown = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isSessionRunning {
            sessionQueue.async {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let videoPreviewLayerConnection = preview.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                    return
            }
            
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    func configureSession(){
    }
    
    func configureVideo(){
        do {
            isInputAvailable = true
            var defaultVideoDevice: AVCaptureDevice?
            
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Video device is not available.")
                isInputAvailable = false
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if self.windowOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    self.preview.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Could not add video device input to the session.")
                isInputAvailable = false
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            isInputAvailable = false
            session.commitConfiguration()
            return
        }
    }
    
    func configureAudio(){
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
    }
    
    @objc func changeCamera() {
        enableCameraButtons(flag: false)
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInTrueDepthCamera
                
            @unknown default:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
            }
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                self.replaceVideoDevice(newVideoDevice: videoDevice)
            }
            
            DispatchQueue.main.async {
                self.enableCameraButtons(flag: true)
            }
        }
    }
    
    func replaceVideoDevice(newVideoDevice videoDevice: AVCaptureDevice){
    }
    
    @objc func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    @objc func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = preview.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    func focus(with focusMode: AVCaptureDevice.FocusMode,
               exposureMode: AVCaptureDevice.ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self,
        selector: #selector(subjectAreaDidChange),
        name: .AVCaptureDeviceSubjectAreaDidChange,
        object: videoDeviceInput.device)
    }
    
    func removeObservers(){
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func close(){
        self.dismiss(animated: true, completion: {
        })
    }
    
}

class CameraPreviewView: UIView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("bad layer type - AVCaptureVideoPreviewLayer expected")
        }
        layer.videoGravity = .resizeAspect
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}

