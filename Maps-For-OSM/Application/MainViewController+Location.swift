/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

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
        showDestructiveApprove(title: "confirmMoveLocation".localize(), text: "\("newLocationHint".localize())\n\(centerCoordinate.asString)"){
            place.coordinate = centerCoordinate
            place.evaluatePlacemark()
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func deletePlace(place: Place) {
        showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationHint".localize()){
            PlacePool.deletePlace(place)
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func showGroupDetails(group: PlaceGroup) {
        if let coordinate = group.centralCoordinate{
            let str = "\(coordinate.asString)\n\(group.places.count) \("location(s)".localize())"
            self.showAlert(title: "groupCenter".localize(), text: str)
            
        }
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
    
    func showDetailsOfCurrentPosition() {
        if let location = LocationService.shared.location{
            LocationService.shared.getPlacemark(for: location){ placemark in
                var str : String
                if let placemark = placemark{
                    str = placemark.locationString + "\n" + location.coordinate.asString
                } else{
                    str = location.coordinate.asString
                }
                self.showAlert(title: "currentPosition".localize(), text: str)
            }
        }
    }
    
    func addLocationAtCurrentPosition() {
        if let coordinate = LocationService.shared.location?.coordinate{
            PlacePool.getPlace(coordinate: coordinate)
            DispatchQueue.main.async {
                self.updateMarkerLayer()
            }
        }
    }
    
    func showDetailsOfCrossPosition() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        LocationService.shared.getPlacemark(for: location){ placemark in
            var str : String
            if let placemark = placemark{
                str = placemark.locationString + "\n" + location.coordinate.asString
            } else{
                str = location.coordinate.asString
            }
            self.showAlert(title: "crossPosition".localize(), text: str)
        }
    }
    
    func addLocationAtCrossPosition() {
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

extension MainViewController: PlaceViewDelegate{
    
    func updateMarkerLayer() {
        mapView.updateLocationLayer()
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
