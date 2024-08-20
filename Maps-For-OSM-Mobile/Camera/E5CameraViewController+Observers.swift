/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos
import E5Data

extension E5CameraViewController{
    
    public func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            
            DispatchQueue.main.async {
                //Log.debug("observers: enable/disable buttons")
                self.cameraButton.isEnabled = isSessionRunning && AVCaptureDevice.DiscoverySession(deviceTypes: E5CameraViewController.discoverableDeviceTypes, mediaType: .video, position: .unspecified).uniqueDevicePositionsCount > 1
                self.captureButton.isEnabled = isSessionRunning
                self.captureModeControl.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: currentDevice)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
    }
    
    public func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if !isCaptureEnabled{
            return
        }
        if context == &systemPreferredCameraContext {
            guard let systemPreferredCamera = change?[.newKey] as? AVCaptureDevice else { return }
            if let movieFileOutput = self.movieFileOutput, movieFileOutput.isRecording {
                return
            }
            if self.currentDevice == systemPreferredCamera {
                return
            }
            //Log.debug("changing device by observer")
            self.changeVideoDevice(systemPreferredCamera)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        Log.error("Capture session runtime error: \(error)")
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    
}
