/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

extension MainViewController: LocationLayerViewDelegate{
    
    func showLocationDetails(location: Location) {
        let controller = LocationDetailViewController(location: location)
        controller.location = location
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func moveLocationToScreenCenter(location: Location) {
        let centerCoordinate = mapView.scrollView.screenCenterCoordinate
        showDestructiveApprove(title: "confirmMoveLocation".localize(), text: "\("newLocationHint".localize())\n\(centerCoordinate.asString)"){
            location.coordinate = centerCoordinate
            location.evaluatePlacemark()
            LocationPool.save()
            self.updateMarkerLayer()
        }
    }
    
    func deleteLocation(location: Location) {
        showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationHint".localize()){
            LocationPool.deleteLocation(location)
            LocationPool.save()
            self.updateMarkerLayer()
        }
    }
    
    func showGroupDetails(group: LocationGroup) {
        if let coordinate = group.centralCoordinate{
            let str = "\(coordinate.asString)\n\(group.locations.count) \("location(s)".localize())"
            self.showAlert(title: "groupCenter".localize(), text: str)
            
        }
    }
    
    func mergeGroup(group: LocationGroup) {
        if let mergedLocation = group.centralLocation{
            showDestructiveApprove(title: "confirmMergeGroup".localize(), text: "\("newLocationHint".localize())\n\(mergedLocation.coordinate.asString)"){
                LocationPool.list.append(mergedLocation)
                LocationPool.list.removeAllOf(group.locations)
                LocationPool.save()
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
            LocationPool.getLocation(coordinate: coordinate)
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
        LocationPool.getLocation(coordinate: mapView.scrollView.screenCenterCoordinate)
        DispatchQueue.main.async {
            self.updateMarkerLayer()
        }
    }
    
    func addImageAtCrossPosition() {
        let location = LocationPool.getLocation(coordinate: mapView.scrollView.screenCenterCoordinate)
        addImage(location: location)
    }
    
}

extension MainViewController: LocationViewDelegate{
    
    func updateMarkerLayer() {
        mapView.updateLocationLayer()
    }
    
}

extension MainViewController: LocationListDelegate{
    
    func showLocationOnMap(location: Location) {
        mapView.scrollView.scrollToScreenCenter(coordinate: location.coordinate)
    }
    
    func deleteLocationFromList(location: Location) {
        LocationPool.deleteLocation(location)
        LocationPool.save()
        updateMarkerLayer()
    }

}
