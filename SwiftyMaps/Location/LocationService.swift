/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

protocol LocationServiceDelegate{
    func locationDidChange(location: CLLocation)
    func directionDidChange(direction: CLLocationDirection)
}

class LocationService : NSObject, CLLocationManagerDelegate{
    
    static var shared = LocationService()
    
    var lastLocation : CLLocation? = nil
    var lastDirection : CLLocationDirection = 0
    var running = false
    var delegate : LocationServiceDelegate? = nil
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private var lock = DispatchSemaphore(value: 1)
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = 2.0
        
    }
    
    var authorized : Bool{
        switch locationManager.authorizationStatus{
        case .authorizedAlways:
            return true
        case.authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    var authorizedForTracking : Bool{
        locationManager.authorizationStatus == .authorizedAlways
    }
    
    func getPlacemarkInfo(for location: Place){
        geocoder.reverseGeocodeLocation(location.cllocation, completionHandler: { (placemarks, error) in
            if error == nil, let placemark =  placemarks?[0]{
                location.addPlacemarkInfo(placemark: placemark)
            }
        })
    }
    
    func start(){
        lock.wait()
        defer{lock.signal()}
        if authorized, !running{
            Log.log("Location service starting")
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.startUpdatingHeading()
            running = true
        }
    }
    
    func checkRunning(){
        if authorized && !running{
            start()
        }
    }
    
    func stop(){
        if running{
            Log.log("Location service stopping")
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
        }
    }
    
    func requestWhenInUseAuthorization(){
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization(){
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Log.log("Location service changed authorization")
        checkRunning()
        if authorized, let loc = lastLocation{
            delegate?.locationDidChange(location: loc)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        if loc.horizontalAccuracy == -1{
            return
        }
        lastLocation = loc
        delegate?.locationDidChange(location: loc)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        lastDirection = newHeading.trueHeading
        delegate?.directionDidChange(direction: lastDirection)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        Log.log("Location updates paused")
        running = false
        if let loc = lastLocation{
            let monitoredRegion = CLCircularRegion(center: loc.coordinate, radius: 5.0, identifier: "monitoredRegion")
            locationManager.startMonitoring(for: monitoredRegion)
        }
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        Log.log("Location updates resumed")
        running = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Log.log("Location exited monitored region")
        if region.identifier == "monitoredRegion"{
            locationManager.stopMonitoring(for: region)
            if authorized{
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                running = true
            }
        }
    }
    
}

