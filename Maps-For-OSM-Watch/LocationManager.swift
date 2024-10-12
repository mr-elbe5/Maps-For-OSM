//
//  Location.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 05.10.24.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate{
    func locationChanged(_ location: CLLocation)
    func directionChanged(_ direction: CLLocationDirection)
}

class LocationManager: NSObject{
    
    static var instance: LocationManager = LocationManager()
    
    static var startLocation = CLLocation(latitude: 53.5419, longitude: 9.6831)
    static var startDirection : CLLocationDirection = 0
    
    var location: CLLocation = LocationManager.startLocation
    var direction: CLLocationDirection = LocationManager.startDirection
    
    var locationDelegate: LocationManagerDelegate? = nil
    
    private let clManager = CLLocationManager()

    override init() {
        super.init()
        clManager.delegate = self
        clManager.allowsBackgroundLocationUpdates = true
    }
    
    deinit{
        stop()
    }
    
    func start(){
        clManager.startUpdatingLocation()
        clManager.startUpdatingHeading()
    }
    
    func stop(){
        clManager.stopUpdatingLocation()
        clManager.stopUpdatingHeading()
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last, loc.horizontalAccuracy != -1{
            location = loc
            locationDelegate?.locationChanged(loc)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if abs(newHeading.trueHeading - direction) > 5{
            direction = newHeading.trueHeading
            locationDelegate?.directionChanged(direction)
        }
    }
    
}
