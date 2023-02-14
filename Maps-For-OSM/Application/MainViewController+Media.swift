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
    func addPhotoAtCurrentPosition() {
        AVCaptureDevice.askCameraAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let imageCaptureController = PhotoCaptureViewController()
                    imageCaptureController.delegate = self
                    imageCaptureController.modalPresentationStyle = .fullScreen
                    self.present(imageCaptureController, animated: true)
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
    
    //MapPositionDelegate
    func addVideoAtCurrentPosition(){
        AVCaptureDevice.askVideoAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let videoCaptureController = VideoCaptureViewController()
                    videoCaptureController.delegate = self
                    videoCaptureController.modalPresentationStyle = .fullScreen
                    self.present(videoCaptureController, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showError("MainViewController videoNotAuthorized")
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
            else if let location = LocationService.shared.location{
                assertLocation(coordinate: location.coordinate){ location in
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
        }
        picker.dismiss(animated: false)
    }
    
}

extension MainViewController: PhotoCaptureDelegate{
    
    func photoCaptured(photo: ImageFile) {
        if let location = LocationService.shared.location{
            assertLocation(coordinate: location.coordinate){ location in
                let changeState = location.media.isEmpty
                //Log.debug("MainViewController adding photo to location, current media count = \(location.media.count)")
                location.addMedia(file: photo)
                //Log.debug("new media count = \(location.media.count)")
                LocationPool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
        }
    }
    
}

extension MainViewController: VideoCaptureDelegate{
    
    func videoCaptured(data: VideoFile){
        if let location = LocationService.shared.location{
            assertLocation(coordinate: location.coordinate){ location in
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
    
}

extension MainViewController: AudioCaptureDelegate{
    
    func audioCaptured(data: AudioFile){
        if let location = LocationService.shared.location{
            assertLocation(coordinate: location.coordinate){ location in
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
    
}

