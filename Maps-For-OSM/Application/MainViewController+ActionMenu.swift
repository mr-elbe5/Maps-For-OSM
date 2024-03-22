/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation
import Photos
import PhotosUI

extension MainViewController: ActionMenuDelegate{
    
    func startTrackRecording(at coordinate: CLLocationCoordinate2D) {
        if let location = LocationService.shared.location{
            TrackRecorder.startRecording(startLocation: location)
            if let track = TrackRecorder.track{
                TrackPool.visibleTrack = track
                self.mapView.trackLayerView.setNeedsDisplay()
                self.statusView.startTrackInfo()
            }
        }
    }
    
    func pauseTrackRecording() {
        TrackRecorder.pauseRecording()
        self.statusView.pauseTrackInfo()
    }
    
    func resumeTrackRecording() {
        TrackRecorder.resumeRecording()
        self.statusView.resumeTrackInfo()
    }
    
    func endTrackRecording(at coordinate: CLLocationCoordinate2D?, onCompletion: @escaping () -> Void) {
        if let track = TrackRecorder.track{
            let alertController = UIAlertController(title: "endTrack".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
            alertController.addTextField()
            alertController.addAction(UIAlertAction(title: "save".localize(),style: .default) { action in
                var name = alertController.textFields![0].text
                if name == nil || name!.isEmpty{
                    name = "Tour"
                }
                track.name = name!
                TrackPool.addTrack(track: track)
                TrackPool.save()
                TrackPool.visibleTrack = track
                self.mapView.trackLayerView.setNeedsDisplay()
                TrackRecorder.stopRecording()
                self.statusView.stopTrackInfo()
                self.mapView.updatePlaceLayer()
                onCompletion()
            })
            alertController.addAction(UIAlertAction(title: "delete".localize(),style: .default) { action in
                TrackRecorder.stopRecording()
                TrackPool.visibleTrack = nil
                self.mapView.trackLayerView.setNeedsDisplay()
                self.statusView.stopTrackInfo()
                onCompletion()
            })
            alertController.addAction(UIAlertAction(title: "cancel".localize(),style: .default) { action in
                onCompletion()
            })
            present(alertController, animated: true)
        }
    }
    
    func hideTrack() {
        TrackPool.visibleTrack = nil
        mapView.trackLayerView.setNeedsDisplay()
    }
    
    func openCamera(at coordinate: CLLocationCoordinate2D) {
        AVCaptureDevice.askCameraAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let cameraCaptureController = CameraViewController()
                    cameraCaptureController.delegate = self
                    cameraCaptureController.modalPresentationStyle = .fullScreen
                    self.present(cameraCaptureController, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showAlert(title: "error".localize(), text: "cameraNotAuthorized".localize())
                }
                return
            }
        }
    }
    
    func openAudio(at coordinate: CLLocationCoordinate2D){
        AVCaptureDevice.askAudioAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let audioCaptureController = AudioRecorderViewController()
                    audioCaptureController.modalPresentationStyle = .fullScreen
                    self.present(audioCaptureController, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showError("MainViewController audioNotAuthorized")
                }
                return
            }
        }
    }
    
    func openNote(at coordinate: CLLocationCoordinate2D) {
        //todo
    }
    
}

