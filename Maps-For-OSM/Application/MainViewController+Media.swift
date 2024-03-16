/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation

extension MainViewController{
    
    func addImage(at coordinate: CLLocationCoordinate2D) {
        let pickerController = ImagePickerController()
        pickerController.coordinate = coordinate
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
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
    
    func addAudio(at coordinate: CLLocationCoordinate2D){
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
    
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL, let pickerController = picker as? ImagePickerController else {return}
        let image = ImageFile()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            if let coordinate = pickerController.coordinate{
                let location = PlacePool.getPlace(coordinate: coordinate)
                let changeState = location.media.isEmpty
                location.addMedia(file: image)
                PlacePool.save()
                if changeState{
                    DispatchQueue.main.async {
                        self.updateMarkerLayer()
                    }
                }
            }
            else if let coordinate = LocationService.shared.location?.coordinate{
                let location = PlacePool.getPlace(coordinate: coordinate)
                let changeState = location.media.isEmpty
                location.addMedia(file: image)
                PlacePool.save()
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
    
    func photoCaptured(data: Data, cllocation: CLLocation?) {
        if let cllocation = cllocation{
            let imageFile = ImageFile()
            imageFile.saveFile(data: data)
            print("photo saved locally")
            let location = PlacePool.getPlace(coordinate: cllocation.coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: imageFile)
            PlacePool.save()
            if changeState{
                self.markersChanged()
            }
        }
    }
    
    func getImageWithImageData(data: Data, properties: NSDictionary) -> Data{

        let imageRef: CGImageSource = CGImageSourceCreateWithData((data as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: data)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (properties as CFDictionary))
        CGImageDestinationFinalize(destination)
        return dataWithEXIF as Data
    }
    
    func videoCaptured(data: Data, cllocation: CLLocation?) {
        if let cllocation = cllocation{
            let videoFile = VideoFile()
            videoFile.saveFile(data: data)
            print("video saved locally")
            let location = PlacePool.getPlace(coordinate: cllocation.coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: videoFile)
            PlacePool.save()
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
            let location = PlacePool.getPlace(coordinate: coordinate)
            let changeState = location.media.isEmpty
            location.addMedia(file: data)
            PlacePool.save()
            if changeState{
                DispatchQueue.main.async {
                    self.updateMarkerLayer()
                }
            }
        }
    }
    
}


