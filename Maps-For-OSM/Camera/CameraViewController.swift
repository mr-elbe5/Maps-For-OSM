/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos

protocol CameraDelegate{
    func photoCaptured(data: Data)
    func videoCaptured(data: Data)
}

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoOutputReadinessCoordinatorDelegate {
    
    static var isMainController = false
    
    static var discoverableDeviceTypes : [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInUltraWideCamera,.builtInTelephotoCamera]
    static var maxLensZoomFactor = 10.0
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    let locationManager = CLLocationManager()
    
    var bodyView = UIView()
    let previewView = PreviewView()
    let captureModeControl = UISegmentedControl()
    let hdrVideoModeButton = CameraIconButton()
    let flashModeButton = CameraIconButton()
    let closeButton = CameraIconButton()
    let zoomLabel = UILabel(text: "1.0x")
    
    let cameraUnavailableLabel = UILabel(text: "cameraUnavailable".localize(table: "Camera"))
    
    let backLensControl = UISegmentedControl()
    let captureButton = CaptureButton()
    let cameraButton = CameraIconButton()
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    let pinchGestureRecognizer = UIPinchGestureRecognizer()
    
    var currentZoom = 1.0
    var currentZoomAtBegin = 1.0
    var currentMaxZoom = 1.0
    
    var isHdrVideoMode = false
    var isPhotoMode = true
    var flashMode: AVCaptureDevice.FlashMode = .auto
    var backDevices = [AVCaptureDevice]()
    var currentBackCameraIndex = 0
    var frontDevice: AVCaptureDevice!
    
    let session = AVCaptureSession()
    var isSessionRunning = false
    let sessionQueue = DispatchQueue(label: "session queue")
    var setupResult: SessionSetupResult = .success
    
    var isCaptureEnabled = false
    // check for isCaptureEnabled!
    var currentDeviceInput: AVCaptureDeviceInput!
    var currentDevice: AVCaptureDevice{
        currentDeviceInput.device
    }
    var currentPosition: AVCaptureDevice.Position{
        currentDevice.position
    }
    
    var videoDeviceRotationCoordinator: AVCaptureDevice.RotationCoordinator!
    var videoDeviceIsConnectedObservation: NSKeyValueObservation?
    var videoRotationAngleForHorizonLevelPreviewObservation: NSKeyValueObservation?
    
    var selectedMovieMode10BitDeviceFormat: AVCaptureDevice.Format?
    
    let photoOutput = AVCapturePhotoOutput()
    var photoOutputReadinessCoordinator: AVCapturePhotoOutputReadinessCoordinator!
    var photoSettings: AVCapturePhotoSettings!
    var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    var movieFileOutput: AVCaptureMovieFileOutput?
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    var _supportedInterfaceOrientations: UIInterfaceOrientationMask = .all
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return _supportedInterfaceOrientations }
        set { _supportedInterfaceOrientations = newValue }
    }
    override var shouldAutorotate: Bool {
        if let movieFileOutput = movieFileOutput {
            return !movieFileOutput.isRecording
        }
        return true
    }
    
    var keyValueObservations = [NSKeyValueObservation]()
    var systemPreferredCameraContext = 0
    
    var delegate: CameraDelegate? = nil
    
    override func loadView() {
        super.loadView()
        view.addSubviewFillingSafeArea(bodyView)
        bodyView.backgroundColor = .black
        bodyView.addSubview(previewView)
        previewView.fillView(view: bodyView)
        discoverDeviceTypes()
        addControls()
    }
    
    func discoverDeviceTypes(){
        let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: CameraViewController.discoverableDeviceTypes, mediaType: .video, position: .front)
        if let device = frontVideoDeviceDiscoverySession.devices.first{
            frontDevice = device
        }
        //print("found front camera")
        backDevices.removeAll()
        let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: CameraViewController.discoverableDeviceTypes, mediaType: .video, position: .back)
        for device in backVideoDeviceDiscoverySession.devices where !device.isVirtualDevice{
            backDevices.append(device)
        }
        //print("found \(backCameras.count) back cameras")
    }
    
    func resetZoomForNewDevice(){
        if !isCaptureEnabled{
            return
        }
        currentDevice.videoZoomFactor = 1.0
        currentZoom = 1.0
        currentZoomAtBegin = 1.0
        currentMaxZoom = min(CameraViewController.maxLensZoomFactor, currentDevice.maxAvailableVideoZoomFactor)
        DispatchQueue.main.async {
            self.updateZoomLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hdrVideoModeButton.isHidden = true
        previewView.session = session
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            setupResult = .notAuthorized
        }
        sessionQueue.async {
            self.configureSession()
            if !self.isCaptureEnabled{
                DispatchQueue.main.async {
                    let sampleView = UIImageView(image: UIImage(named: "sample"))
                    sampleView.setAspectRatioConstraint()
                    self.previewView.addSubview(sampleView)
                    sampleView.setAnchors(centerX: self.previewView.centerXAnchor, centerY: self.previewView.centerYAnchor)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "E5Cam", message: "noPrivacyPermission".localize(table: "Camera"), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "ok".localize(table: "Base"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "settings".localize(table: "Base"), style: .`default`, handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "E5Cam", message: "captureFailed".localize(table: "Camera"), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "ok".localize(table: "Base"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    func changeVideoDevice(_ videoDevice: AVCaptureDevice, completion: (() -> Void)? = nil) {
        sessionQueue.async {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                self.session.beginConfiguration()
                if let currentDeviceInput = self.currentDeviceInput{
                    self.session.removeInput(currentDeviceInput)
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: self.currentDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        self.session.addInput(videoDeviceInput)
                        self.currentDeviceInput = videoDeviceInput
                        self.isCaptureEnabled = true
                        DispatchQueue.main.async {
                            self.createDeviceRotationCoordinator()
                        }
                    } else {
                        self.session.addInput(currentDeviceInput)
                    }
                }
                if self.isCaptureEnabled, let connection = self.movieFileOutput?.connection(with: .video) {
                    self.session.sessionPreset = .high
                    self.selectedMovieMode10BitDeviceFormat = self.tenBitVariantOfFormat(activeFormat: self.currentDevice.activeFormat)
                    if self.selectedMovieMode10BitDeviceFormat != nil {
                        DispatchQueue.main.async {
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
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.configurePhotoOutput()
                self.resetZoomForNewDevice()
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.updateZoomLabel()
                }
            } catch {
                print("Error occurred while creating video device input: \(error)")
            }
        }
        completion?()
    }
    
    func readinessCoordinator(_ coordinator: AVCapturePhotoOutputReadinessCoordinator, captureReadinessDidChange captureReadiness: AVCapturePhotoOutput.CaptureReadiness) {
        self.captureButton.isUserInteractionEnabled = (captureReadiness == .ready) ? true : false
    }
    
    func createDeviceRotationCoordinator() {
        if !isCaptureEnabled{
            return
        }
        videoDeviceRotationCoordinator = AVCaptureDevice.RotationCoordinator(device: currentDevice, previewLayer: previewView.videoPreviewLayer)
        previewView.videoPreviewLayer.connection?.videoRotationAngle = videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelPreview
        
        videoRotationAngleForHorizonLevelPreviewObservation = videoDeviceRotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: .new) { _, change in
            guard let videoRotationAngleForHorizonLevelPreview = change.newValue else { return }
            
            self.previewView.videoPreviewLayer.connection?.videoRotationAngle = videoRotationAngleForHorizonLevelPreview
        }
    }
    
    func focus(with focusMode: AVCaptureDevice.FocusMode,
               exposureMode: AVCaptureDevice.ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {
        if !isCaptureEnabled{
            return
        }
        sessionQueue.async {
            let device = self.currentDevice
            do {
                try device.lockForConfiguration()
                
                // Setting (focus/exposure)PointOfInterest alone does not
                // initiate a (focus/exposure) operation. Call
                // set(Focus/Exposure)Mode() to apply the new point of interest.
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
    
    func setUpPhotoSettings() -> AVCapturePhotoSettings {
        var photoSettings = AVCapturePhotoSettings()
        if !isCaptureEnabled{
            return photoSettings
        }
        if self.photoOutput.availablePhotoCodecTypes.contains(AVVideoCodecType.jpeg) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        if currentDevice.isFlashAvailable {
            photoSettings.flashMode = flashMode
        }
        photoSettings.maxPhotoDimensions = self.photoOutput.maxPhotoDimensions
        if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
        }
        photoSettings.photoQualityPrioritization = .quality
        return photoSettings
    }
    
    func tenBitVariantOfFormat(activeFormat: AVCaptureDevice.Format) -> AVCaptureDevice.Format? {
        if !isCaptureEnabled{
            return nil
        }
        let formats = currentDevice.formats
        let formatIndex = formats.firstIndex(of: activeFormat)!
        
        let activeDimensions = CMVideoFormatDescriptionGetDimensions(activeFormat.formatDescription)
        let activeMaxFrameRate = activeFormat.videoSupportedFrameRateRanges.last?.maxFrameRate
        let activePixelFormat = CMFormatDescriptionGetMediaSubType(activeFormat.formatDescription)
        
        if activePixelFormat != kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange {
            for index in formatIndex + 1..<formats.count {
                let format = formats[index]
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
                let pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription)
                if activeMaxFrameRate != maxFrameRate || activeDimensions.width != dimensions.width || activeDimensions.height != dimensions.height {
                    break
                }
                if pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange {
                    return format
                }
            }
        } else {
            return activeFormat
        }
        return nil
    }
    
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions = [AVCaptureDevice.Position]()
        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        return uniqueDevicePositions.count
    }
}
