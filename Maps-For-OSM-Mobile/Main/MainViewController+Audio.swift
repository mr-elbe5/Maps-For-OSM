/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation

extension MainViewController: AudioCaptureDelegate{
    
    func openAudioRecorder(at coordinate: CLLocationCoordinate2D){
        AVCaptureDevice.askAudioAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let controller = AudioRecorderViewController()
                    controller.delegate = self
                    controller.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(controller, animated: true)
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
    
    func audioCaptured(audio: AudioItem){
        if let coordinate = LocationService.shared.location?.coordinate{
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: coordinate)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: coordinate)
                newLocation = true
            }
            location!.addItem(item: audio)
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


