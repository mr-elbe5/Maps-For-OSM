//
//  Location.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 05.10.24.
//

import Foundation
import CoreLocation

@Observable class LocationManager: NSObject{
    
    //center de
    static var startLocation = CLLocation(latitude: 51.165691, longitude: 10.4515269)
    // north
    static var startDirection : CLLocationDirection = 0
    
    static var shared: LocationManager = LocationManager()
    
    var location: CLLocation = LocationManager.startLocation
    var direction: CLLocationDirection = LocationManager.startDirection
    
    private let clManager = CLLocationManager()

    override init() {
        super.init()
        clManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        clManager.distanceFilter = 10.0
        clManager.headingFilter = 5.0
        clManager.delegate = self
        clManager.allowsBackgroundLocationUpdates = true
    }
    
    deinit{
        stop()
    }
    
    func start(){
        print("starting location manager")
        clManager.startUpdatingLocation()
        startFollowDirection()
    }
    
    func stop(){
        print("stopping location manager")
        clManager.stopUpdatingLocation()
        clManager.stopUpdatingHeading()
    }
    
    func startFollowDirection(){
        if WatchPreferences.shared.showDirection{
            clManager.startUpdatingHeading()
        }
    }
    
    func stopFollowDirection(){
        clManager.stopUpdatingHeading()
    }
    
    func updateFollowDirection(){
        if WatchPreferences.shared.showDirection{
            clManager.startUpdatingHeading()
        }else{
            clManager.stopUpdatingHeading()
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last, loc.horizontalAccuracy != -1{
            location = loc
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        direction = newHeading.trueHeading
    }
    
}
