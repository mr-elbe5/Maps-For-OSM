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
    
    func toggleMovieRecording() {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        enableControls(false)
        let videoRotationAngle = self.videoDeviceRotationCoordinator.videoRotationAngleForHorizonLevelCapture
        if let window = self.view.window, let windowScene = window.windowScene {
            switch windowScene.interfaceOrientation {
            case .portrait: self.supportedInterfaceOrientations = .portrait
            case .landscapeLeft: self.supportedInterfaceOrientations = .landscapeLeft
            case .landscapeRight: self.supportedInterfaceOrientations = .landscapeRight
            case .portraitUpsideDown: self.supportedInterfaceOrientations = .portraitUpsideDown
            case .unknown: self.supportedInterfaceOrientations = .portrait
            default: self.supportedInterfaceOrientations = .portrait
            }
        }
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                print("start movie recording")
                DispatchQueue.main.async {
                    //print("movie recording: change capture button to recording")
                    self.captureButton.buttonState = .recording
                }
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoRotationAngle = videoRotationAngle
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                DispatchQueue.main.async {
                    //print("movie recording: enable only capture button")
                    self.captureButton.isEnabled = true
                }
            } else {
                movieFileOutput.stopRecording()
                print("stop movie recording")
                DispatchQueue.main.async {
                    //print("movie recording: reset capture button")
                    self.captureButton.buttonState = .normal
                    self.enableControls(true)
                }
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        if success {
            let data = FileController.readFile(url: outputFileURL)!
            let videoFile = VideoFile()
            videoFile.saveFile(data: data)
            print("video saved locally")
            if let location = LocationService.shared.location{
                assertLocation(coordinate: location.coordinate){ location in
                    let changeState = location.media.isEmpty
                    location.addMedia(file: videoFile)
                    LocationPool.save()
                    if changeState{
                        self.delegate?.markersChanged()
                    }
                }
            }
            PhotoLibrary.saveVideo(outputFileURL: outputFileURL, location: self.locationManager.location, resultHandler: { success in
                cleanup()
            })
        } else {
            cleanup()
        }
        sessionQueue.async {
            if let systemPreferredCamera = AVCaptureDevice.systemPreferredCamera{
                if self.currentDevice != systemPreferredCamera {
                    self.changeVideoDevice(systemPreferredCamera)
                }
            }
        }
        DispatchQueue.main.async {
            //print("file output: enable buttons")
            self.cameraButton.isEnabled = AVCaptureDevice.DiscoverySession(deviceTypes: CameraViewController.discoverableDeviceTypes, mediaType: .video, position: .unspecified).uniqueDevicePositionsCount > 1
            self.captureButton.isEnabled = true
            self.captureModeControl.isEnabled = true
            self.supportedInterfaceOrientations = UIInterfaceOrientationMask.all
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
        
    }
    
}
