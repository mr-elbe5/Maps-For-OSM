/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5MapData

extension MainViewController: MainMenuDelegate, ActionMenuDelegate, MapMenuDelegate{
    
    func showLocations(_ show: Bool) {
        AppState.shared.showLocations = show
        mapView.locationLayerView.isHidden = !AppState.shared.showLocations
    }
    
    func deleteAllLocations(){
        showDestructiveApprove(title: "confirmDeleteLocations".localize(), text: "deleteLocationsHint".localize()){
            AppData.shared.deleteAllLocations()
            AppData.shared.save()
            self.locationsChanged()
        }
    }
    
    func addLocation(at coordinate: CLLocationCoordinate2D) {
        if let _ = AppData.shared.getLocation(coordinate: coordinate){
            return
        }
        let location = AppData.shared.createLocation(coordinate: coordinate)
        DispatchQueue.main.async {
            self.locationAdded(location: location)
        }
    }
    
    func focusUserLocation() {
        mapView.focusUserLocation()
    }
    
    func updateCross() {
        mapView.crossLocationView.isHidden = !AppState.shared.showCross
    }
    
    func refreshMap() {
        mapView.refresh()
    }
    
    func zoomIn() {
        if AppState.shared.zoom < World.maxZoom{
            mapView.zoomTo(zoom: AppState.shared.zoom + 1, animated: true)
        }
    }
    
    func zoomOut() {
        if AppState.shared.zoom > World.minZoom{
            mapView.zoomTo(zoom: AppState.shared.zoom - 1, animated: true)
        }
    }
    
}

extension MainViewController: MapPositionDelegate{
    
    func showCrossLocationMenu() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let controller = CrossLocationMenuViewController(coordinate: coordinate, title: "crossLocation".localize())
        controller.delegate = self
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
    
}

extension MainViewController: LocationLayerDelegate{
    
    func showLocationDetails(location: Location) {
        let controller = LocationViewController(location: location)
        controller.location = location
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func deleteLocation(location: Location) {
        showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationHint".localize()){
            AppData.shared.deleteLocation(location)
            AppData.shared.save()
            self.locationDeleted(location: location)
        }
    }
    
    func showGroupDetails(group: LocationGroup) {
        let controller = LocationGroupViewController(group: group)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}



