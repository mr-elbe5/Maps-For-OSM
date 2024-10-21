/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI

extension MainViewController: LocationServiceDelegate{
    
    func locationDidChange(location: CLLocation) {
        mapView.locationDidChange(location: location)
        if let trackRecorder = TrackRecorder.instance, location.horizontalAccuracy <= Preferences.shared.maxHorizontalUncertainty{
            if TrackRecorder.isRecording{
                TrackRecorder.instance?.track.addTrackpoint(from: location)
                trackChanged()
                if Preferences.shared.followTrack{
                    mapView.focusUserLocation()
                }
                statusView.updateTrackInfo()
            }
            else if trackRecorder.track.trackpoints.isEmpty, let cancelAlert = cancelAlert{
                Log.info("closing GPS wait alert")
                cancelAlert.dismiss(animated: false)
                self.cancelAlert = nil
                startTrackRecording(at: location)
                actionMenuView.updateTrackingButton()
            }
            
        }
        statusView.updateLocationInfo(location: location)
    }
    
    func directionDidChange(direction: CLLocationDirection) {
        mapView.setDirection(direction)
        statusView.updateDirection(direction: direction)
    }
    
}

extension MainViewController: LocationDelegate{
    
    func locationsChanged() {
        mapView.updateLocationLayer()
    }
    
    func locationChanged(location: Location) {
        mapView.updateLocation(for: location)
    }
    
    func showLocationOnMap(coordinate: CLLocationCoordinate2D) {
        mapView.showLocationOnMap(coordinate: coordinate)
    }
    
}


