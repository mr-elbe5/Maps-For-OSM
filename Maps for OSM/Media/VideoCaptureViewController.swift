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
    
    func videoCaptured(data: VideoData)
}

class VideoCaptureViewController: CameraViewController, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var data : VideoData!
    
    var delegate: VideoCaptureDelegate? = nil
    
    var libraryButton = UIButton().asIconButton("photo", color: .white)
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    var tmpFileName = "mptvideo"
    var tmpFilePath : String!
    var tmpFileURL : URL!
    
    override func loadView() {
        super.loadView()
        tmpFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((tmpFileName as NSString).appendingPathExtension("mp4")!)
        tmpFileURL = URL(fileURLWithPath: tmpFilePath)
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
        } catch {
            print("Error occurred while creating video device input: \(error)")
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
        if error != nil {
            print("Video file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        if success {
            let videoData = VideoData()
            if let fileData = FileManager.default.contents(atPath: tmpFilePath){
                let url = FileController.getURL(dirURL: FileController.privateURL,fileName: videoData.fileName)
                _ = FileController.saveFile(data: fileData, url: url)
                cleanup()
                delegate?.videoCaptured(data: videoData)
                self.dismiss(animated: true)
            }
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
        if FileManager.default.fileExists(atPath: tmpFilePath) {
            do {
                try FileManager.default.removeItem(atPath: tmpFilePath)
            } catch {
                print("Could not remove file at url: \(String(describing: tmpFileURL))")
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let videoURL = info[.mediaURL] as? URL else {return}
        if FileController.copyFile(fromURL: videoURL, toURL: data.fileURL){
            delegate?.videoCaptured(data: data)
            picker.dismiss(animated: false){
                self.dismiss(animated: true)
            }
        }
        else{
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
}




