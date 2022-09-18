//
//  World.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation
import CoreLocation

class World{
    
    static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    
    static let maxZoom : Int = 18
    static var minZoom : Int = 4
    static let tileExtent : Double = 256.0
    static let tileSize : MapSize = MapSize(width: tileExtent, height: tileExtent)
    static let fullExtent : Double = pow(2,Double(maxZoom))*tileExtent
    static let equatorInMeters : CGFloat = 40075016.686
    static let worldSize = CGSize(width: fullExtent, height: fullExtent)
    static let mapSize = MapSize(width: fullExtent, height: fullExtent)
    
    static let mapRect = MapRect(origin: MapPoint(x: 0, y: 0), size: mapSize)
    
    static var scrollWidthFactor : CGFloat = 3
    static var scrollableWorldSize = CGSize(width: scrollWidthFactor*fullExtent, height: fullExtent)
    
    static func minimumZoomLevelForViewSize(viewSize: CGSize) -> Int{
        for z in 0..<10{
            let zoomPixels = zoomScale(at: z)*tileExtent
            if (zoomPixels > viewSize.width) && (zoomPixels > viewSize.height){
                return max(minZoom, z)
            }
        }
        return minZoom
    }
    
    static func zoomScale(at zoom: Int) -> Double{
        pow(2.0, CGFloat(zoom))
    }
    
    static func zoomScale(from: Int, to: Int) -> Double{
        zoomScale(at: to - from)
    }
    
    static func zoomScaleToWorld(from zoom: Int) -> Double{
        zoomScale(from: zoom, to: maxZoom)
    }
    
    static func zoomScaleFromWorld(to zoom: Int) -> Double{
        zoomScale(from: maxZoom, to: zoom)
    }
    
    static func zoomLevelFromScale(scale: CGFloat) -> Int{
        Int(round(log2(scale)))
    }
    
    static func zoomedWorld(zoom: Int) -> MapRect{
        let scale = zoomScale(from: maxZoom, to: zoom)
        return MapRect(x: 0, y: 0, width: fullExtent*scale, height: fullExtent*scale)
    }
    
    static func xPos(longitude: CLLocationDegrees) -> Double{
       (longitude + 180)/360.0
    }
    
    static func yPos(latitude: CLLocationDegrees) -> Double{
        (1.0 - log(tan(latitude*CGFloat.pi/180.0) + 1/cos(latitude*CGFloat.pi/180.0 ))/CGFloat.pi)/2
    }
    
    static func latitudeDegreesForMeters(_ meters: CLLocationDistance) -> CLLocationDegrees{
        meters/equatorInMeters*360
    }
    
    static func longitudeDegreesForMetersAtLatitude(_ meters: CLLocationDistance, lat: CLLocationDegrees) -> CLLocationDegrees{
        meters/equatorInMeters*360*cos(lat)
    }
    
    static func metersPerMapPointAtLatitude(_ lat: CLLocationDegrees) -> CLLocationDistance{
        156543.03 * cos(lat)
    }
    
    static func mapPointsPerMeterAtLatitude(_ lat: CLLocationDegrees) -> Double{
        1/metersPerMapPointAtLatitude(lat)
    }
    
}