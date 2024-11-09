/*
 IOS Basics
 Basic classes and extensions for reuse
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CoreLocation

typealias TrackpointList = Array<Trackpoint>

extension TrackpointList{
    
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
    
    var boundingMapRect: CGRect?{
        if let boundingCoordinates = boundingCoordinates{
            let topLeft = CGPoint(boundingCoordinates.topLeft)
            let bottomRight = CGPoint(boundingCoordinates.bottomRight)
            return CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
        }
        return nil
    }
    
}


