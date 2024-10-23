//
//  Location.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 05.10.24.
//

import Foundation
import CoreLocation

@Observable class LocationManager: NSObject{
    
    // north
    static var startDirection : CLLocationDirection = 0
    
    static var shared: LocationManager = LocationManager()
    
    var location: CLLocation? = nil
    var direction: CLLocationDirection = LocationManager.startDirection
    
    private let clManager = CLLocationManager()

    override init() {
        super.init()
        clManager.activityType = .other
        clManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        clManager.distanceFilter = 10.0
        clManager.headingFilter = 5.0
        clManager.delegate = self
        clManager.allowsBackgroundLocationUpdates = true
    }
    
    deinit{
        stop()
    }
    
    func assertLocation(_ gotLocation: @escaping (CLLocation) -> Void){
        if let location = location{
            gotLocation(location)
        }
        else{
            PhoneConnector.instance.requestLocation( completion: { location in
                if let location = location{
                    self.location = location
                    gotLocation(location)
                }
            })
        }
    }
    
    func start(){
        print("starting location manager")
        clManager.startUpdatingLocation()
        if Preferences.shared.showDirection{
            startFollowDirection()
        }
    }
    
    func stop(){
        print("stopping location manager")
        clManager.stopUpdatingLocation()
        clManager.stopUpdatingHeading()
    }
    
    func startFollowDirection(){
        if Preferences.shared.showDirection{
            clManager.startUpdatingHeading()
        }
    }
    
    func stopFollowDirection(){
        clManager.stopUpdatingHeading()
    }
    
    func updateFollowDirection(){
        if Preferences.shared.showDirection{
            clManager.startUpdatingHeading()
        }else{
            clManager.stopUpdatingHeading()
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied :
            // Alert
            print("Denied")
        case .restricted:
            print("restricted")
        case .notDetermined:
            // Request
            print("not Determined")
            manager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse :
            print("Authorized when in use")
            manager.allowsBackgroundLocationUpdates = true
            manager.startUpdatingLocation()
        default:
            print("Default")
        }
    }
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last, loc.horizontalAccuracy != -1{
            location = loc
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        direction = newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error: \(error)")    
    }
    
}
