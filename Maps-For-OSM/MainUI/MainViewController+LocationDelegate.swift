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
    
    func addPlace(at coordinate: CLLocationCoordinate2D) {
        if let _ = PlacePool.getPlace(coordinate: coordinate){
            return
        }
        let _ = PlacePool.createPlace(coordinate: coordinate)
        DispatchQueue.main.async {
            self.placesChanged()
        }
    }
    
    func deletePlaceFromList(place: Place) {
        PlacePool.deletePlace(place)
        PlacePool.save()
        placesChanged()
    }
    
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
        let image = Image()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            var coordinate: CLLocationCoordinate2D?
            if let coord = pickerController.coordinate{
                coordinate = coord
            }
            else{
                coordinate = LocationService.shared.location?.coordinate
            }
            if let coordinate = coordinate{
                var newPlace = false
                var place = PlacePool.getPlace(coordinate: coordinate)
                if place == nil{
                    place = PlacePool.createPlace(coordinate: coordinate)
                    newPlace = true
                }
                place!.addItem(item: image)
                PlacePool.save()
                DispatchQueue.main.async {
                    if newPlace{
                        self.placesChanged()
                    }
                    else{
                        self.placeChanged(place: place!)
                    }
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
    
    func addNote(text: String, coordinate: CLLocationCoordinate2D) {
        if !text.isEmpty{
            var newPlace = false
            var place = PlacePool.getPlace(coordinate: coordinate)
            if place == nil{
                place = PlacePool.createPlace(coordinate: coordinate)
                newPlace = true
            }
            let note = Note()
            note.text = text
            place!.addItem(item: note)
            PlacePool.save()
            DispatchQueue.main.async {
                if newPlace{
                    self.placesChanged()
                }
                else{
                    self.placeChanged(place: place!)
                }
            }
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
            let imageFile = Image()
            imageFile.saveFile(data: data)
            Log.debug("photo saved locally")
            var newPlace = false
            var place = PlacePool.getPlace(coordinate: cllocation.coordinate)
            if place == nil{
                place = PlacePool.createPlace(coordinate: cllocation.coordinate)
                newPlace = true
            }
            place!.addItem(item: imageFile)
            PlacePool.save()
            DispatchQueue.main.async {
                if newPlace{
                    self.placesChanged()
                }
                else{
                    self.placeChanged(place: place!)
                }
            }
        }
    }
    
    func videoCaptured(data: Data, cllocation: CLLocation?) {
        if let cllocation = cllocation{
            let videoFile = Video()
            videoFile.saveFile(data: data)
            var newPlace = false
            var place = PlacePool.getPlace(coordinate: cllocation.coordinate)
            if place == nil{
                place = PlacePool.createPlace(coordinate: cllocation.coordinate)
                newPlace = true
            }
            place!.addItem(item: videoFile)
            PlacePool.save()
            DispatchQueue.main.async {
                if newPlace{
                    self.placesChanged()
                }
                else{
                    self.placeChanged(place: place!)
                }
            }
        }
    }
    
    func openAudioRecorder(at coordinate: CLLocationCoordinate2D){
        AVCaptureDevice.askAudioAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let audioCaptureController = AudioRecorderViewController()
                    audioCaptureController.delegate = self
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
    
    func audioCaptured(audio: Audio){
        if let coordinate = LocationService.shared.location?.coordinate{
            var newPlace = false
            var place = PlacePool.getPlace(coordinate: coordinate)
            if place == nil{
                place = PlacePool.createPlace(coordinate: coordinate)
                newPlace = true
            }
            place!.addItem(item: audio)
            PlacePool.save()
            DispatchQueue.main.async {
                if newPlace{
                    self.placesChanged()
                }
                else{
                    self.placeChanged(place: place!)
                }
            }
        }
    }
    
    func startTrackRecording(at coordinate: CLLocationCoordinate2D) {
        if let location = LocationService.shared.location{
            TrackRecorder.startRecording(startLocation: location)
            if let track = TrackRecorder.track{
                Track.visibleTrack = track
                self.trackChanged()
                self.trackStatusView.isHidden = false
                self.statusView.isHidden = true
                self.trackStatusView.startTrackInfo()
            }
        }
    }
    
    func saveTrack() {
        if let track = TrackRecorder.track, let coordinate = track.startCoordinate{
            track.name = "trackName".localize(param: track.startTime.dateString())
            var newPlace = false
            var place = PlacePool.getPlace(coordinate: coordinate)
            if place == nil{
                place = PlacePool.createPlace(coordinate: coordinate)
                newPlace = true
            }
            place!.addItem(item: track)
            PlacePool.save()
            Track.visibleTrack = track
            self.trackChanged()
            TrackRecorder.stopRecording()
            self.trackStatusView.isHidden = true
            self.statusView.isHidden = false
            DispatchQueue.main.async {
                if newPlace{
                    self.placesChanged()
                }
                else{
                    self.placeChanged(place: place!)
                }
            }
        }
    }
    
    func cancelTrack() {
        if TrackRecorder.track != nil{
            TrackRecorder.stopRecording()
            Track.visibleTrack = nil
            self.trackChanged()
            self.trackStatusView.stopTrackInfo()
            self.trackStatusView.isHidden = true
            self.statusView.isHidden = false
        }
    }
    
}


