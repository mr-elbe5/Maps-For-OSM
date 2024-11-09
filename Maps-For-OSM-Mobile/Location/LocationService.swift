/*
 E5MapData
 Base classes and extension for IOS and MacOS
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
    
    private var lock = DispatchSemaphore(value: 1)
    
    override init() {
        super.init()
        delegate = self
        desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        distanceFilter = 5.0
        headingFilter = 5.0
        
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
    
    func start(){
        Log.info("LocationService start")
        lock.wait()
        defer{lock.signal()}
        if authorized, !running{
            startUpdatingLocation()
            allowsBackgroundLocationUpdates = true
            #if !os(watchOS)
            pausesLocationUpdatesAutomatically = false
            #endif
            #if os(iOS)
            showsBackgroundLocationIndicator = true
            #endif
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
            #if os(iOS)
            stopUpdatingHeading()
            #endif
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
        if let loc = locations.last, loc.horizontalAccuracy != -1, loc.horizontalAccuracy <= Preferences.shared.maxHorizontalUncertainty{
            serviceDelegate?.locationDidChange(location: loc)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        serviceDelegate?.directionDidChange(direction: newHeading.trueHeading)
    }
    
    #if !os(watchOS)
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
    #endif
}

