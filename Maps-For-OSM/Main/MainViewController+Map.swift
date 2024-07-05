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

extension MainViewController: LocationServiceDelegate{
    
    func locationDidChange(location: CLLocation) {
        mapView.locationDidChange(location: location)
        if let trackRecorder = TrackRecorder.instance, location.horizontalAccuracy < Preferences.shared.maxHorizontalUncertainty{
            if TrackRecorder.isRecording{
                TrackRecorder.instance?.track.addTrackpoint(from: location)
                trackChanged()
                if Preferences.shared.followTrack{
                    mapView.focusUserLocation()
                }
                trackStatusView.updateTrackInfo()
            }
            else if trackRecorder.track.trackpoints.isEmpty, let cancelAlert = cancelAlert{
                cancelAlert.dismiss(animated: false)
                self.cancelAlert = nil
                startTrackRecording(at: location)
                actionMenuView.updateTrackingButton()
            }
            
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

extension MainViewController: LocationLayerDelegate{
    
    func showLocationDetails(location: Location) {
        let controller = EditLocationViewController(location: location)
        controller.location = location
        controller.modalPresentationStyle = .fullScreen
        controller.locationDelegate = self
        controller.trackDelegate = self
        present(controller, animated: true)
    }
    
    func deleteLocation(location: Location) {
        showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationHint".localize()){
            AppData.shared.deleteLocation(location)
            AppData.shared.save()
            self.locationsChanged()
        }
    }
    
    func showGroupDetails(group: LocationGroup) {
        let controller = LocationGroupViewController(group: group)
        controller.locationDelegate = self
        controller.trackDelegate = self
        controller.modalPresentationStyle = .popover
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
}

extension MainViewController: LocationDelegate{
    
    func showLocationOnMap(location: Location) {
        mapView.scrollView.scrollToScreenCenter(coordinate: location.coordinate)
    }
    
}

extension MainViewController: ImageDelegate {
    
    func viewImage(image: Image) {
        
    }
    
}

extension MainViewController: TrackDelegate{
    
    func editTrack(item: Track) {
        let controller = EditTrackViewController(track: item)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func showTrackOnMap(item: Track) {
        if !item.trackpoints.isEmpty, let boundingRect = item.trackpoints.boundingMapRect{
            Track.visibleTrack = item
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


