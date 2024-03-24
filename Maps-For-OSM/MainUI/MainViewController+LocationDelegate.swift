/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation

extension MainViewController: LocationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                CameraDelegate, AudioCaptureDelegate, NoteViewDelegate{
    
    func openAddImage(at coordinate: CLLocationCoordinate2D) {
        let pickerController = ImagePickerController()
        pickerController.coordinate = coordinate
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL, let pickerController = picker as? ImagePickerController else {return}
        let image = ImageItem()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            if let coordinate = pickerController.coordinate{
                let place = PlacePool.assertPlace(coordinate: coordinate)
                place.addItem(item: image)
                PlacePool.save()
            DispatchQueue.main.async {
                    self.placeChanged(place: place)
                }
            }
            else if let coordinate = LocationService.shared.location?.coordinate{
                let place = PlacePool.assertPlace(coordinate: coordinate)
                place.addItem(item: image)
                PlacePool.save()
                DispatchQueue.main.async {
                    self.placeChanged(place: place)
                }
            }
        }
        picker.dismiss(animated: false)
    }
    
    func openAddNote(at coordinate: CLLocationCoordinate2D) {
        let controller = NoteViewController(coordinate: coordinate)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func addNote(note: String, coordinate: CLLocationCoordinate2D) {
        if !note.isEmpty{
            let place = PlacePool.assertPlace(coordinate: coordinate)
            let item = NoteItem()
            item.note = note
            place.addItem(item: item)
            PlacePool.save()
        }
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
    
    func photoCaptured(data: Data, location: CLLocation?) {
        if let cllocation = location{
            let imageFile = ImageItem()
            imageFile.saveFile(data: data)
            Log.debug("photo saved locally")
            let place = PlacePool.assertPlace(coordinate: cllocation.coordinate)
            let changeState = place.hasItems
            place.addItem(item: imageFile)
            PlacePool.save()
            if changeState{
                self.placeChanged(place: place)
            }
        }
    }
    
    func videoCaptured(data: Data, cllocation: CLLocation?) {
        if let cllocation = cllocation{
            let videoFile = VideoItem()
            videoFile.saveFile(data: data)
            Log.debug("video saved locally")
            let place = PlacePool.assertPlace(coordinate: cllocation.coordinate)
            place.addItem(item: videoFile)
            PlacePool.save()
            self.placeChanged(place: place)
        }
    }
    
    func openAudioRecorder(at coordinate: CLLocationCoordinate2D){
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
    
    func audioCaptured(item: AudioItem){
        if let coordinate = LocationService.shared.location?.coordinate{
            let location = PlacePool.assertPlace(coordinate: coordinate)
            location.addItem(item: item)
            PlacePool.save()
            DispatchQueue.main.async {
                self.placeChanged(place: item.place)
            }
        }
    }
    
    func startTrackRecording(at coordinate: CLLocationCoordinate2D) {
        if let location = LocationService.shared.location{
            TrackRecorder.startRecording(startLocation: location)
            if let track = TrackRecorder.track{
                TrackPool.visibleTrack = track
                self.trackChanged()
                self.trackStatusView.isHidden = false
                self.statusView.isHidden = true
                self.trackStatusView.startTrackInfo()
            }
        }
    }
    
    func endTrackRecording(at coordinate: CLLocationCoordinate2D?, onCompletion: @escaping () -> Void) {
        if let track = TrackRecorder.track{
            let alertController = UIAlertController(title: "endTrack".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
            alertController.addTextField()
            alertController.addAction(UIAlertAction(title: "saveTrack".localize(),style: .default) { action in
                var name = alertController.textFields![0].text
                if name == nil || name!.isEmpty{
                    name = "Tour"
                }
                track.name = name!
                TrackPool.addTrack(track: track)
                TrackPool.save()
                TrackPool.visibleTrack = track
                self.trackChanged()
                TrackRecorder.stopRecording()
                self.trackStatusView.isHidden = true
                self.statusView.isHidden = false
                self.mapView.updatePlaceLayer()
                onCompletion()
            })
            alertController.addAction(UIAlertAction(title: "cancelTrack".localize(),style: .default) { action in
                TrackRecorder.stopRecording()
                TrackPool.visibleTrack = nil
                self.trackChanged()
                self.trackStatusView.stopTrackInfo()
                self.trackStatusView.isHidden = true
                self.statusView.isHidden = false
                onCompletion()
            })
            alertController.addAction(UIAlertAction(title: "back".localize(),style: .default) { action in
                onCompletion()
            })
            present(alertController, animated: true)
        }
    }
    
}


