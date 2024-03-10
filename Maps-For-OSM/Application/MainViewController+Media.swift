/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVKit

extension MainViewController{
    
    func addImage(location: Location?){
        let pickerController = ImagePickerController()
        pickerController.location = location
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    //LocationLayerViewDelegate
    func addImageToLocation(location: Location) {
        addImage(location: location)
    }
    
    //MapPositionDelegate
    func openCameraAtCurrentPosition() {
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
    
    //MapPositionDelegate
    func addImageAtCurrentPosition() {
        addImage(location: nil)
    }
    
    //MapPositionDelegate
    func addAudioAtCurrentPosition(){
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
    
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL, let pickerController = picker as? ImagePickerController else {return}
        let image = ImageFile()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            if let location = pickerController.location{
                let changeState = location.media.isEmpty
                location.addMedia(file: image)
                LocationPool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
            else if let coordinate = LocationService.shared.location?.coordinate{
                let location = LocationPool.getLocation(coordinate: coordinate)
                let changeState = location.media.isEmpty
                location.addMedia(file: image)
                LocationPool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
        }
        picker.dismiss(animated: false)
    }
    
}

extension MainViewController: CameraDelegate{
    
    func photoCaptured(data: Data) {
        let imageFile = ImageFile()
        imageFile.saveFile(data: data)
        print("photo saved locally")
        if let coordinate = LocationService.shared.location?.coordinate{
            let location = LocationPool.getLocation(coordinate: coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: imageFile)
            LocationPool.save()
            if changeState{
                self.markersChanged()
            }
        }
    }
    
    func videoCaptured(data: Data) {
        let videoFile = VideoFile()
        videoFile.saveFile(data: data)
        print("video saved locally")
        if let coordinate = LocationService.shared.location?.coordinate{
            let location = LocationPool.getLocation(coordinate: coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: videoFile)
            LocationPool.save()
            if changeState{
                self.markersChanged()
            }
        }
    }
    
    func markersChanged() {
        DispatchQueue.main.async {
            self.updateMarkerLayer()
        }
    }
    
}

extension MainViewController: AudioCaptureDelegate{
    
    func audioCaptured(data: AudioFile){
        if let coordinate = LocationService.shared.location?.coordinate{
            let location = LocationPool.getLocation(coordinate: coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: data)
            LocationPool.save()
            if changeState{
                DispatchQueue.main.async {
                    self.updateMarkerLayer()
                }
            }
        }
    }
    
}

