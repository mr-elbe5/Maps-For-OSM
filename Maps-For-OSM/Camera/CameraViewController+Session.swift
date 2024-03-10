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
    
    func configureSession() {
        if setupResult != .success {
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .photo
        do {
            var defaultVideoDevice: AVCaptureDevice? = AVCaptureDevice.systemPreferredCamera
            let userDefaults = UserDefaults.standard
            if !userDefaults.bool(forKey: "setInitialUserPreferredCamera") || defaultVideoDevice == nil {
                let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
                if let device = backVideoDeviceDiscoverySession.devices.first{
                    defaultVideoDevice = device
                }
                else{
                    let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
                    if let device = frontVideoDeviceDiscoverySession.devices.first{
                        defaultVideoDevice = device
                    }
                }
                AVCaptureDevice.userPreferredCamera = defaultVideoDevice
                userDefaults.set(true, forKey: "setInitialUserPreferredCamera")
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            AVCaptureDevice.self.addObserver(self, forKeyPath: "systemPreferredCamera", options: [.new], context: &systemPreferredCameraContext)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.currentDeviceInput = videoDeviceInput
                self.isCaptureEnabled = true
                self.resetZoomForNewDevice()
                DispatchQueue.main.async {
                    self.createDeviceRotationCoordinator()
                    self.updateZoomLabel()
                }
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            //live photos disabled
            photoOutput.isLivePhotoCaptureEnabled = false
            photoOutput.maxPhotoQualityPrioritization = .quality
            
            self.configurePhotoOutput()
            
            let readinessCoordinator = AVCapturePhotoOutputReadinessCoordinator(photoOutput: photoOutput)
            DispatchQueue.main.async {
                self.photoOutputReadinessCoordinator = readinessCoordinator
                readinessCoordinator.delegate = self
            }
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    
}
