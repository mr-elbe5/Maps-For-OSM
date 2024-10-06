//
//  Location.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 05.10.24.
//

import Foundation
import CoreLocation

@Observable class LocationManager: NSObject{
    
    static var instance: LocationManager = LocationManager()
    
    var location: CLLocation = CLLocation(latitude: 53.541905, longitude: 9.683107)
    
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
        }
    }
    
}
