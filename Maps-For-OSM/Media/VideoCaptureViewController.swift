/*
 My Private Track
 App for creating a diary with entry based on time and map location using text, photos, audios and videos
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVFoundation
import Photos

protocol VideoCaptureDelegate{
    
    func videoCaptured(data: VideoFile)
}

class VideoCaptureViewController: CameraViewController, AVCaptureFileOutputRecordingDelegate, UINavigationControllerDelegate {
    
    var delegate: VideoCaptureDelegate? = nil
    
    var libraryButton = UIButton().asIconButton("photo", color: .white)
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    var tmpFileName = "tmpvideo.mp4"
    var tmpFileURL : URL
    
    init(){
        tmpFileURL = FileController.temporaryURL.appendingPathComponent(tmpFileName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addCameraButtons(){
        
        cameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        cameraButton.target(forAction: #selector(changeCamera), withSender: self)
        cameraButton.addTarget(self, action: #selector(changeCamera), for: .touchDown)
        view.addSubview(cameraButton)
        cameraButton.setAnchors(top: view.topAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
            .height(20)
        
        captureButton.buttonColor = UIColor.red
        captureButton.addTarget(self, action: #selector(toggleRecording), for: .touchDown)
        bodyView.addSubview(captureButton)
        captureButton.setAnchors(bottom: view.bottomAnchor, insets: defaultInsets)
            .centerX(bodyView.centerXAnchor)
            .width(50)
            .height(50)
        
    }
    
    override func enableCameraButtons(flag: Bool){
        libraryButton.isEnabled = flag
        captureButton.isEnabled = flag
        cameraButton.isEnabled = flag
    }
    
    override func configureSession(){
        session.beginConfiguration()
        session.sessionPreset = .photo
        configureVideo()
        if !isInputAvailable{
            return
        }
        configureAudio()
        configureMovieOutput()
        session.commitConfiguration()
    }
    
    func configureMovieOutput(){
        sessionQueue.async {
            let movieFileOutput = AVCaptureMovieFileOutput()
            
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.addOutput(movieFileOutput)
                self.session.sessionPreset = .high
                if let connection = movieFileOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.session.commitConfiguration()
                self.movieFileOutput = movieFileOutput
                DispatchQueue.main.async {
                    self.captureButton.isEnabled = true
                }
            }
        }
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
            if let connection = self.movieFileOutput?.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            
            self.session.commitConfiguration()
        } catch let err{
            Log.error("VideoCaptureViewController while creating video device input", error: err)
        }
    }
    
    override var shouldAutorotate: Bool {
        if let movieFileOutput = movieFileOutput {
            return !movieFileOutput.isRecording
        }
        return true
    }
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    @objc func toggleRecording() {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        
        cameraButton.isEnabled = false
        captureButton.isEnabled = false
        
        let videoPreviewLayerOrientation = preview.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.h264) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: movieFileOutputConnection!)
                }
                movieFileOutput.startRecording(to: self.tmpFileURL, recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.captureButton.isEnabled = true
            self.captureButton.buttonState = .recording
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        var success = true
        if let error = error {
            Log.error(msg: "VideoCaptureViewController file finishing error", error: error)
            success = (((error as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        if success {
            //Log.debug("VideoCaptureViewController outputURL = \(outputFileURL)")
            let acceptController = VideoAcceptViewController(videoUrl: outputFileURL)
            acceptController.modalPresentationStyle = .fullScreen
            acceptController.delegate = self
            present(acceptController, animated: true)
        }
        else{
            self.cleanup()
        }
        DispatchQueue.main.async {
            self.captureButton.isEnabled = true
            self.captureButton.buttonState = .normal
        }
    }
    
    func cleanup() {
        if FileManager.default.fileExists(atPath: tmpFileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: tmpFileURL.path)
            } catch let err{
                Log.error("VideoCaptureViewController Could not remove file at url: \(String(describing: tmpFileURL))", error: err)
            }
        }
        
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
            
            if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
    }
    
    override func addObservers(){
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            DispatchQueue.main.async {
                self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.captureButton.isEnabled = isSessionRunning && self.movieFileOutput != nil
            }
        }
        keyValueObservations.append(keyValueObservation)
        NotificationCenter.default.addObserver(self,
        selector: #selector(subjectAreaDidChange),
        name: .AVCaptureDeviceSubjectAreaDidChange,
        object: videoDeviceInput.device)
    }
    
}

extension VideoCaptureViewController: VideoAcceptDelegate{
    
    func videoAccepted(videoUrl: URL, title: String) {
        //Log.debug("VideoCaptureViewController video accepted")
        let videoFile = VideoFile()
        //Log.debug("VideoCaptureViewController title = \(title)")
        videoFile.title = title
        if FileController.copyFile(fromURL: videoUrl, toURL: FileController.getURL(dirURL: FileController.mediaDirURL,fileName: videoFile.fileName)){
            cleanup()
            self.dismiss(animated: true){
                self.delegate?.videoCaptured(data: videoFile)
            }
        }
    }
    
    func videoDismissed() {
        //Log.debug("VideoCaptureViewController photo dismissed")
    }
    
    
    
    
}

protocol VideoAcceptDelegate{
    func videoAccepted(videoUrl: URL, title: String)
    func videoDismissed()
}

class VideoAcceptViewController: PopupScrollViewController{
    
    var videoUrl : URL
    
    var titleField = UITextField()
    var saveButton = UIButton()
    var cancelButton = UIButton()
    
    var delegate: VideoAcceptDelegate? = nil
    
    init(videoUrl: URL){
        self.videoUrl = videoUrl
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        scrollView.backgroundColor = .black
        let videoView = VideoPlayerView()
        videoView.setRoundedBorders()
        videoView.url = videoUrl
        videoView.setAspectRatioConstraint()
        contentView.addSubviewWithAnchors(videoView, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        titleField.setDefaults(placeholder: "comment".localize())
        titleField.backgroundColor = .white
        titleField.setKeyboardToolbar(doneTitle: "done".localize())
        contentView.addSubviewWithAnchors(titleField, top: videoView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        saveButton.asTextButton("accept".localize(), color: .systemBlue, backgroundColor: .white)
        saveButton.addTarget(self, action: #selector(accepted), for: .touchDown)
        contentView.addSubviewWithAnchors(saveButton, top: titleField.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        cancelButton.asTextButton("cancel".localize(), color: .darkGray, backgroundColor: .lightGray)
        cancelButton.addTarget(self, action: #selector(dismissed), for: .touchDown)
        contentView.addSubviewWithAnchors(cancelButton, top: saveButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
            .centerX(view.centerXAnchor)
        setupKeyboard()
    }
    
    override func createHeaderView() {
    }
    
    @objc func accepted(){
        dismiss(animated: false){
            self.delegate?.videoAccepted(videoUrl: self.videoUrl, title: self.titleField.text!.trim())
        }
    }
    
    @objc func dismissed(){
        self .dismiss(animated: false){
            self.delegate?.videoDismissed()
        }
    }
    
}




