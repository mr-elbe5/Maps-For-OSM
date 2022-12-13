/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class LocationGroup{
    
    var center: CLLocationCoordinate2D? = nil
    var centerPlanetPosition: CGPoint? = nil
    var locations = LocationList()
    
    var hasPhotos: Bool{
        for location in locations{
            if location.hasFiles{
                return true
            }
        }
        return false
    }
    
    var hasTracks: Bool{
        for location in locations{
            if location.hasTracks{
                return true
            }
        }
        return false
    }
    
    func isWithinRadius(location: Location, radius: CGFloat) -> Bool{
        debug("LocationGroup checkking radius")
        if let center = center{
            let dist = center.distance(to: location.coordinate)
            debug("dist = \(dist) at radius \(radius)")
            return dist <= radius
        }
        else{
            return false
        }
    }
    
    func hasLocation(location: Location) -> Bool{
        locations.contains(location)
    }
    
    func addLocation(location: Location){
        locations.append(location)
    }
    
    func setCenter(){
        var minLon : CGFloat? = nil
        var maxLon : CGFloat? = nil
        var minLat : CGFloat? = nil
        var maxLat : CGFloat? = nil
        
        for loc in locations{
            minLon = min(minLon ?? CGFloat.greatestFiniteMagnitude, loc.coordinate.longitude)
            maxLon = max(maxLon ?? -CGFloat.greatestFiniteMagnitude, loc.coordinate.longitude)
            minLat = min(minLat ?? CGFloat.greatestFiniteMagnitude, loc.coordinate.latitude)
            maxLat = max(maxLat ?? -CGFloat.greatestFiniteMagnitude, loc.coordinate.latitude)
        }
        if let minX = minLon,let maxX = maxLon, let minY = minLat, let maxY = maxLat{
            center = CLLocationCoordinate2D(latitude: (minY + maxY)/2, longitude: (minX + maxX)/2)
            centerPlanetPosition = MapPoint(center!).cgPoint
        }
    }
    
}
