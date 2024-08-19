/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

open class GPXData{
    
    public var name: String = ""
    public var segments = [GPXSegment]()
    
    public var isEmpty: Bool{
        get{
            segments.isEmpty || segments.first!.isEmpty
        }
    }
    
}

public class GPXSegment{
    
    public var points = [GPXPoint]()
    
    public var isEmpty: Bool{
        get{
            points.isEmpty
        }
    }
    
}

public class GPXPoint{
    
    public var coordinate : CLLocationCoordinate2D
    public var altitude : CLLocationDistance = 0
    public var timestamp : Date? = nil
    
    public var location: CLLocation{
        get{
            CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: timestamp ?? Date())
        }
    }
    
    public init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
    
}
