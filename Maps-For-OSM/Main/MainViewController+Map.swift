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
import E5Data
import E5IOSUI
import E5MapData
import Maps_For_OSM_Data

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
    
    func showCrossLocationMenu() {
        let coordinate = mapView.scrollView.screenCenterCoordinate
        let controller = CrossLocationMenuViewController(coordinate: coordinate, title: "crossLocation".localize())
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
        controller.placeDelegate = self
        controller.trackDelegate = self
        present(controller, animated: true)
    }
    
    func deletePlace(place: Place) {
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            AppData.shared.deletePlace(place)
            AppData.shared.saveLocally()
            self.placesChanged()
        }
    }
    
    func showGroupDetails(group: PlaceGroup) {
        let controller = PlaceGroupViewController(group: group)
        controller.placeDelegate = self
        controller.trackDelegate = self
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

extension MainViewController: ImageDelegate {
    
    func viewImage(image: ImageItem) {
        
    }
    
}

extension MainViewController: TrackDelegate{
    
    func viewTrackItem(item: TrackItem) {
        let controller = TrackViewController(track: item)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func showTrackItemOnMap(item: TrackItem) {
        if !item.trackpoints.isEmpty, let boundingRect = item.trackpoints.boundingMapRect{
            TrackItem.visibleTrack = item
            trackChanged()
            mapView.scrollView.scrollToScreenCenter(coordinate: boundingRect.centerCoordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: boundingRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
    }
    
}

extension MainViewController: SearchDelegate{
    
    func getCurrentRegion() -> CoordinateRegion {
        mapView.scrollView.visibleRegion
    }
    
    func getCurrentCenter() -> CLLocationCoordinate2D {
        mapView.scrollView.screenCenterCoordinate
    }
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, mapRect: CGRect?) {
        if let mapRect = mapRect{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
            mapView.scrollView.setZoomScale(World.getZoomScaleToFit(mapRect: mapRect, scaledBounds: mapView.bounds)*0.9, animated: true)
        }
        else{
            mapView.scrollView.scrollToScreenCenter(coordinate: coordinate)
        }
    }
    
}


