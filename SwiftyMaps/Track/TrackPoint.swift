/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class TrackPoint: CodableLocation{
    
    var timeDiff: CGFloat = 0
    var horizontalDistance: CGFloat = 0
    var verticalDistance: CGFloat = 0
    var horizontalSpeed: CGFloat = 0
    var verticalSpeed: CGFloat = 0
    
    var valid = false
    
    func calculateDeltas(to tp: TrackPoint){
        guard timeDiff != 0 else {return}
        timeDiff = tp.timestamp.distance(to: timestamp)
        horizontalDistance = tp.coordinate.distance(to: coordinate)
        verticalDistance = altitude - tp.altitude
        horizontalSpeed = horizontalDistance/timeDiff
        verticalSpeed = verticalDistance/timeDiff
    }
}

typealias TrackPointList = Array<TrackPoint>

extension TrackPointList{
    
    var distance: CGFloat{
        var d: CGFloat = 0
        for tp in self{
            d += tp.horizontalDistance
        }
        return d
    }
    
    var upDistance: CGFloat{
        var d: CGFloat = 0
        for tp in self{
            if tp.verticalDistance > 0{
                d += tp.verticalDistance
            }
        }
        return d
    }
    
    var downDistance: CGFloat{
        var d: CGFloat = 0
        for tp in self{
            if tp.verticalDistance < 0{
                d -= tp.verticalDistance
            }
        }
        return d
    }
    
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
    
    func invalidate(){
        if count == 0{
            return
        }
        self[0].valid = true
        for i in 1..<count{
            self[i].valid = false
        }
    }
    
}


