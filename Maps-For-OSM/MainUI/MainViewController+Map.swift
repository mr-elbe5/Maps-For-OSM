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
    
    func showCurrentLocationMenu() {
        let coordinate = LocationService.shared.location?.coordinate ?? CLLocationCoordinate2D()
        let controller = LocationMenuViewController(coordinate: coordinate, title: "currentLocation".localize())
        controller.delegate = self
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
    
    func showCrossLocationMenu() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let controller = LocationMenuViewController(coordinate: coordinate, title: "crossLocation".localize())
        controller.delegate = self
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true)
    }
    
}

extension MainViewController: PlaceLayerDelegate{
    
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
            self.placesChanged()
        }
    }
    
    func showGroupDetails(group: PlaceGroup) {
        let controller = PlaceGroupViewController(group: group)
        controller.modalPresentationStyle = .popover
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
}

extension MainViewController: PlaceDelegate{
    
    func showPlaceOnMap(place: Place) {
        mapView.scrollView.scrollToScreenCenter(coordinate: place.coordinate)
    }
    
}

extension MainViewController: TrackDelegate{
    
    func viewTrackItem(item: Track) {
        
    }
    
    func showTrackItemOnMap(item: Track) {
        if !item.trackpoints.isEmpty, let boundingRect = item.trackpoints.boundingMapRect{
            Track.visibleTrack = item
            trackChanged()
            mapView.scrollView.scrollToScreenCenter(coordinate: boundingRect.centerCoordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: boundingRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
    }
    
}


extension MainViewController: ImageDelegate {
    
    func viewImage(image: Image) {
        
    }
    
}

extension MainViewController: TrackDetailDelegate{
    
    func viewTrackDetails(track: Track) {
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
    
    func getCurrentCenter() -> CLLocationCoordinate2D {
        mapView.scrollView.screenCenterCoordinate
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


