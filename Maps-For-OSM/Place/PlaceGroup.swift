/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class PlaceGroup{
    
    var center: CLLocationCoordinate2D? = nil
    var centerPlanetPosition: CGPoint? = nil
    var places = PlaceList()
    
    var hasMedia: Bool{
        for place in places{
            if place.hasMedia{
                return true
            }
        }
        return false
    }
    
    var hasTrack: Bool{
        for place in places{
            if place.hasTrack{
                return true
            }
        }
        return false
    }
    
    var centralCoordinate: CLLocationCoordinate2D?{
        let count = places.count
        if count < 2{
            return nil
        }
        var lat = 0.0
        var lon = 0.0
        for place in places{
            lat += place.coordinate.latitude
            lon += place.coordinate.longitude
        }
        lat = lat/Double(count)
        lon = lon/Double(count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func isWithinRadius(place: Place, radius: CGFloat) -> Bool{
        //debug("LocationGroup checking radius")
        if let center = center{
            let dist = center.distance(to: place.coordinate)
            //debug("dist = \(dist) at radius \(radius)")
            return dist <= radius
        }
        else{
            return false
        }
    }
    
    func hasLocation(location: Place) -> Bool{
        places.contains(location)
    }
    
    func addPlace(place: Place){
        places.append(place)
    }
    
    func setCenter(){
        var minLon : CGFloat? = nil
        var maxLon : CGFloat? = nil
        var minLat : CGFloat? = nil
        var maxLat : CGFloat? = nil
        
        for loc in places{
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
