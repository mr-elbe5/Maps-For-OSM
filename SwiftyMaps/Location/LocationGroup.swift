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
    
    var hasMedia: Bool{
        for location in locations{
            if location.hasMedia{
                return true
            }
        }
        return false
    }
    
    var centralCoordinate: CLLocationCoordinate2D?{
        let count = locations.count
        if count < 2{
            return nil
        }
        var lat = 0.0
        var lon = 0.0
        for location in locations{
            lat += location.coordinate.latitude
            lon += location.coordinate.longitude
        }
        lat = lat/Double(count)
        lon = lon/Double(count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var centralLocation: Location?{
        let count = locations.count
        if count < 2{
            return nil
        }
        var lat = 0.0
        var lon = 0.0
        var note = ""
        var mediaList = MediaList()
        for location in locations{
            lat += location.coordinate.latitude
            lon += location.coordinate.longitude
            note += location.note
            for mediaFile in location.media{
                mediaList.append(mediaFile)
            }
        }
        lat = lat/Double(count)
        lon = lon/Double(count)
        try? mediaList.sort(by: MediaData.areInIncreasingDateOrder)
        let location = Location(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        location.evaluatePlacemark()
        location.note = note
        location.media = mediaList
        return location
    }
    
    func isWithinRadius(location: Location, radius: CGFloat) -> Bool{
        //debug("LocationGroup checking radius")
        if let center = center{
            let dist = center.distance(to: location.coordinate)
            //debug("dist = \(dist) at radius \(radius)")
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
