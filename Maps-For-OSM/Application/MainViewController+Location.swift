/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation

extension MainViewController: PlaceLayerViewDelegate{
    
    func showPlaceDetails(place: Place) {
        let controller = PlaceDetailViewController(location: place)
        controller.place = place
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func movePlaceToScreenCenter(place: Place) {
        let centerCoordinate = mapView.scrollView.screenCenterCoordinate
        showDestructiveApprove(title: "confirmMovePlace".localize(), text: "\("newLocationHint".localize())\n\(centerCoordinate.asString)"){
            place.coordinate = centerCoordinate
            place.evaluatePlacemark()
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func deletePlace(place: Place) {
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            PlacePool.deletePlace(place)
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func showGroupDetails(group: PlaceGroup) {
        let controller = PlaceGroupViewController(group: group)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func mergeGroup(group: PlaceGroup) {
        if let mergedLocation = group.centralPlace{
            showDestructiveApprove(title: "confirmMergeGroup".localize(), text: "\("newLocationHint".localize())\n\(mergedLocation.coordinate.asString)"){
                PlacePool.list.append(mergedLocation)
                PlacePool.list.removeAllOf(group.places)
                PlacePool.save()
                self.updateMarkerLayer()
            }
        }
    }
    
}

extension MainViewController: MapPositionDelegate{
    
    func showDetailsOfUserLocation() {
        let coordinate = LocationService.shared.location?.coordinate ?? CLLocationCoordinate2D()
        let controller = UserLocationViewController(coordinate: coordinate)
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func showDetailsOfCrossPosition() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let controller = CrossLocationViewController(coordinate: coordinate)
        controller.delegate = self
        present(controller, animated: true)
    }
    
}

extension MainViewController: PlaceViewDelegate{
    
    func updateMarkerLayer() {
        mapView.updateLocationLayer()
    }
    
}

extension MainViewController: PlaceGroupViewDelegate{
    
    
    
}

extension MainViewController: CrossLocationDelegate{
    
    func addPlaceAtCrossPosition() {
        PlacePool.getPlace(coordinate: mapView.scrollView.screenCenterCoordinate)
        DispatchQueue.main.async {
            self.updateMarkerLayer()
        }
    }
    
    func addImageAtCrossPosition() {
        let location = PlacePool.getPlace(coordinate: mapView.scrollView.screenCenterCoordinate)
        addImage(location: location)
    }
    
}

extension MainViewController: UserLocationDelegate{
    
    func addPlaceAtUserLocation() {
        if let coordinate = LocationService.shared.location?.coordinate{
            PlacePool.getPlace(coordinate: coordinate)
            DispatchQueue.main.async {
                self.updateMarkerLayer()
            }
        }
    }
    
    func openCameraAtUserLocation() {
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
    
    func addImageAtUserLocation() {
        addImage(location: nil)
    }
    
    func addAudioAtUserLocation(){
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

extension MainViewController: PlaceListDelegate{
    
    func showPlaceOnMap(place: Place) {
        mapView.scrollView.scrollToScreenCenter(coordinate: place.coordinate)
    }
    
    func deletePlaceFromList(place: Place) {
        PlacePool.deletePlace(place)
        PlacePool.save()
        updateMarkerLayer()
    }

}
