/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation
import Photos
import PhotosUI

extension MainViewController: LocationServiceDelegate{
    
    func locationDidChange(location: CLLocation) {
        mapView.locationDidChange(location: location)
        if TrackRecorder.isRecording{
            if TrackRecorder.updateTrack(with: location){
                trackChanged()
                if Preferences.shared.followTrack{
                    mapView.focusUserLocation()
                }
            }
            trackStatusView.updateTrackInfo()
        }
        if statusView.isDetailed{
            statusView.updateDetailInfo(location: location)
        }
    }
    
    func directionDidChange(direction: CLLocationDirection) {
        mapView.setDirection(direction)
        statusView.updateDirection(direction: direction)
    }
    
}

extension MainViewController: MapPositionDelegate{
    
    func showDetailsOfCurrentLocation() {
        let coordinate = LocationService.shared.location?.coordinate ?? CLLocationCoordinate2D()
        let controller = LocationViewController(coordinate: coordinate, title: "currentLocation".localize())
        controller.delegate = self
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
    
    func showDetailsOfCrossLocation() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let controller = LocationViewController(coordinate: coordinate, title: "crossLocation".localize())
        controller.delegate = self
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
    
}

extension MainViewController: PlaceListDelegate, PlaceViewDelegate, PlaceLayerDelegate {
    
    func showPlaceOnMap(place: Place) {
        mapView.scrollView.scrollToScreenCenter(coordinate: place.coordinate)
    }
    
    func deletePlaceFromList(place: Place) {
        PlacePool.deletePlace(place)
        PlacePool.save()
        updateMarkerLayer()
    }
    
    func showPlaceDetails(place: Place) {
        let controller = PlaceViewController(location: place)
        controller.place = place
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func deletePlace(place: Place) {
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            PlacePool.deletePlace(place)
            PlacePool.save()
            self.updateMarkerLayer()
        }
    }
    
    func addPlace(at coordinate: CLLocationCoordinate2D) {
        if let coordinate = LocationService.shared.location?.coordinate{
            PlacePool.assertPlace(coordinate: coordinate)
            DispatchQueue.main.async {
                self.updateMarkerLayer()
            }
        }
    }
    
    func showTrackItemOnMap(item: TrackItem) {
        if !item.trackpoints.isEmpty, let boundingRect = item.trackpoints.boundingMapRect{
            TrackItem.visibleTrack = item
            trackChanged()
            mapView.scrollView.scrollToScreenCenter(coordinate: boundingRect.centerCoordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: boundingRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
    }
    
    
    func showGroupDetails(group: PlaceGroup) {
        let controller = PlaceGroupViewController(group: group)
        controller.modalPresentationStyle = .popover
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func mergeGroup(group: PlaceGroup) {
        if let mergedLocation = group.centralPlace{
            showDestructiveApprove(title: "confirmMergeGroup".localize(), text: "\("newLocationHint".localize())\n\(mergedLocation.coordinate.asString)"){
                PlacePool.places.append(mergedLocation)
                PlacePool.places.removeAllOf(group.places)
                PlacePool.save()
                self.updateMarkerLayer()
            }
        }
    }
}

extension MainViewController: TrackDetailDelegate, TrackListDelegate{
    
    func placeChanged(place: Place) {
        //todo
        mapView.updatePlaceLayer()
    }
    
    func placesChanged() {
        mapView.updatePlaceLayer()
    }
    
    func viewTrackDetails(track: TrackItem) {
        let controller = TrackViewController(track: track)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func trackChanged() {
        mapView.trackLayerView.setNeedsDisplay()
    }
    
}

extension MainViewController: SearchDelegate{
    
    func getCurrentRegion() -> CoordinateRegion {
        mapView.scrollView.visibleRegion
    }
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, mapRect: MapRect?) {
        if let mapRect = mapRect{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: mapRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
        else{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
        }
    }
    
}


