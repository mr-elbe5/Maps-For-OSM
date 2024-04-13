/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

protocol LocationServiceDelegate{
    func locationDidChange(location: CLLocation)
    func directionDidChange(direction: CLLocationDirection)
}

class LocationService : CLLocationManager, CLLocationManagerDelegate{
    
    static var shared = LocationService()
    
    var running = false
    
    var serviceDelegate: LocationServiceDelegate? = nil
    
    private let placemarkService = PlacemarkService()
    
    private var lock = DispatchSemaphore(value: 1)
    
    override init() {
        super.init()
        delegate = self
        desiredAccuracy = kCLLocationAccuracyBest
        distanceFilter = kCLDistanceFilterNone
        headingFilter = 2.0
        
    }
    
    var authorized : Bool{
        switch authorizationStatus{
        case .authorizedAlways:
            return true
        case.authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    var authorizedForTracking : Bool{
        authorizationStatus == .authorizedAlways
    }
    
    func getPlacemark(for place: Place, result: @escaping(CLPlacemark?) -> Void){
        placemarkService.getPlacemark(for: place, result: result)
    }
    
    func getPlacemark(for location: CLLocation, result: @escaping(CLPlacemark?) -> Void){
        placemarkService.getPlacemark(for: location, result: result)
    }
    
    func start(){
        Log.info("LocationService start")
        lock.wait()
        defer{lock.signal()}
        if authorized, !running{
            startUpdatingLocation()
            allowsBackgroundLocationUpdates = true
            pausesLocationUpdatesAutomatically = false
            showsBackgroundLocationIndicator = true
            startUpdatingHeading()
            running = true
        }
    }
    
    func checkRunning(){
        if authorized && !running{
            start()
        }
    }
    
    func stop(){
        Log.info("LocationService stop")
        if running{
            stopUpdatingLocation()
            stopUpdatingHeading()
            running = false
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkRunning()
        if authorized, let loc = location{
            serviceDelegate?.locationDidChange(location: loc)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        if loc.horizontalAccuracy == -1{
            return
        }
        serviceDelegate?.locationDidChange(location: loc)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        serviceDelegate?.directionDidChange(direction: newHeading.trueHeading)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        Log.info("LocationService pause")
        running = false
        if let loc = location{
            let monitoredRegion = CLCircularRegion(center: loc.coordinate, radius: 5.0, identifier: "monitoredRegion")
            startMonitoring(for: monitoredRegion)
        }
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        Log.info("LocationService resume")
        running = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "monitoredRegion"{
            stopMonitoring(for: region)
            if authorized{
                startUpdatingLocation()
                startUpdatingHeading()
                running = true
            }
        }
    }
    
}

