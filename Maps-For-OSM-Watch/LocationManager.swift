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
}

class LocationManager: NSObject{
    
    static var instance: LocationManager = LocationManager()
    
    static var startLocation = CLLocation(latitude: 53.5419, longitude: 9.6831)
    
    var location: CLLocation = LocationManager.startLocation
    
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
    }
    
    func stop(){
        clManager.stopUpdatingLocation()
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updating location")
        if let loc = locations.last{
            location = loc
            print(loc)
            locationDelegate?.locationChanged(loc)
        }
    }
    
}
