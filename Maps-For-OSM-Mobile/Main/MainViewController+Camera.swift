/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation
import PhotosUI
import E5Data
import E5IOSUI

extension MainViewController: CameraDelegate{
    
    func openCamera(at coordinate: CLLocationCoordinate2D) {
        AVCaptureDevice.askCameraAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let controller = CameraViewController()
                    controller.delegate = self
                    controller.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(controller, animated: true)
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
            var imageData = data
            if let dataWithCoordinates = data.setImageProperties(altitude: cllocation.altitude, latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude, utType: imageFile.fileURL.utType!){
                imageData = dataWithCoordinates
            }
            
            imageFile.saveFile(data: imageData)
            Log.info("photo saved locally as \(imageFile.fileName)")
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: cllocation.coordinate)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: cllocation.coordinate)
                newLocation = true
            }
            location!.addItem(item: imageFile)
            AppData.shared.save()
            DispatchQueue.main.async {
                if newLocation{
                    self.locationsChanged()
                }
                else{
                    self.locationChanged(location: location!)
                }
                self.showLocationOnMap(coordinate: location!.coordinate)
            }
        }
    }
    
    func videoCaptured(data: Data, cllocation: CLLocation?) {
        if let cllocation = cllocation{
            let videoFile = VideoItem()
            videoFile.saveFile(data: data)
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: cllocation.coordinate)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: cllocation.coordinate)
                newLocation = true
            }
            location!.addItem(item: videoFile)
            AppData.shared.save()
            DispatchQueue.main.async {
                if newLocation{
                    self.locationsChanged()
                }
                else{
                    self.locationChanged(location: location!)
                }
                self.showLocationOnMap(coordinate: location!.coordinate)
            }
        }
    }
    
}


