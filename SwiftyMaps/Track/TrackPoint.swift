/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

typealias TrackPoint = CodableLocation

typealias TrackPointList = Array<TrackPoint>

extension TrackPointList{
    
    var boundingCoordinates: (topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D)?{
        get{
            if isEmpty{
                return nil
            }
            var coord = self[0].coordinate
            var top = coord.latitude
            var bottom = coord.latitude
            var left = coord.longitude
            var right = coord.longitude
            for i in 1..<count{
                coord = self[i].coordinate
                top = Swift.max(top, coord.latitude)
                bottom = Swift.min(bottom, coord.latitude)
                left = Swift.min(left, coord.longitude)
                right = Swift.max(right, coord.longitude)
            }
            return (topLeft: CLLocationCoordinate2D(latitude: top,longitude: left),
                    bottomRight: CLLocationCoordinate2D(latitude: bottom,longitude: right))
        }
    }
    
    var boundingMapRect: MapRect?{
        if let boundingCoordinates = boundingCoordinates{
            let topLeft = MapPoint(boundingCoordinates.topLeft)
            let bottomRight = MapPoint(boundingCoordinates.bottomRight)
            return MapRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
        }
        return nil
    }
    
}


