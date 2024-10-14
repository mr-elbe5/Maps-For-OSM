//
//  Location.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 05.10.24.
//

import Foundation
import CoreLocation

protocol LocationDelegate{
    func locationChanged(_ location: CLLocation)
}

protocol DirectionDelegate{
    func directionChanged(_ direction: CLLocationDirection)
}

class LocationManager: NSObject{
    
    static var instance: LocationManager = LocationManager()
    
    static var startLocation = CLLocation(latitude: 53.5419, longitude: 9.6831)
    static var startDirection : CLLocationDirection = 0
    
    var location: CLLocation = LocationManager.startLocation
    var direction: CLLocationDirection = LocationManager.startDirection
    
    var locationDelegate: LocationDelegate? = nil
    var directionDelegate: DirectionDelegate? = nil
    
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
        print("starting location manager")
        clManager.startUpdatingLocation()
        clManager.startUpdatingHeading()
    }
    
    func stop(){
        print("stopping location manager")
        clManager.stopUpdatingLocation()
        clManager.stopUpdatingHeading()
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last, loc.horizontalAccuracy != -1{
            location = loc
            DispatchQueue.main.async {
                self.locationDelegate?.locationChanged(loc)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if abs(newHeading.trueHeading - direction) > 5{
            direction = newHeading.trueHeading
            DispatchQueue.main.async {
                self.directionDelegate?.directionChanged(self.direction)
            }
        }
    }
    
}
