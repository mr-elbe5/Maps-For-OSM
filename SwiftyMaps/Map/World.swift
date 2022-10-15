//
//  World.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation
import CoreLocation

struct World{
    
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
    
    static func latitudeDegreesForMeters(_ meters: CLLocationDistance) -> CLLocationDegrees{
        meters/equatorInMeters*360
    }
    
    static func longitudeDegreesForMetersAtLatitude(_ meters: CLLocationDistance, lat: CLLocationDegrees) -> CLLocationDegrees{
        meters/equatorInMeters*360*cos(lat)
    }
    
    static func metersPerMapPointAtLatitude(_ lat: CLLocationDegrees) -> CLLocationDistance{
        equatorInMeters/tileExtent * cos(lat)
    }
    
    static func mapPointsPerMeterAtLatitude(_ lat: CLLocationDegrees) -> Double{
        1/metersPerMapPointAtLatitude(lat)
    }
    
    static func projectedLongitude(_ longitude: Double) -> Double {
        (longitude + 180) / 360.0
    }
    
    static func projectedLatitude(_ latitude: Double) -> Double {
        (1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2
    }
    
    static func tileX(_ longitude: Double) -> Int {
        Int(floor(projectedLongitude(longitude)))
    }
    
    static func tileX(_ longitude: Double, withZoom zoom: Int) -> Int {
        Int(floor(projectedLongitude(longitude) * pow(2.0, Double(zoom))))
    }
    
    static func tileY(_ latitude: Double) -> Int {
        Int(floor(projectedLatitude(latitude)))
    }
    
    static func tileY(_ latitude: Double, withZoom zoom: Int) -> Int {
        Int(floor(projectedLatitude(latitude) * pow(2.0, Double(zoom))))
    }
    
    static func worldX(_ longitude: Double) -> Double {
        round(projectedLongitude(longitude) * World.fullExtent)
    }
    
    static func worldY(_ latitude: Double) -> Double {
        round(projectedLatitude(latitude) * World.fullExtent)
    }
    
    static func coordinate(worldX : Double, worldY : Double) -> CLLocationCoordinate2D {
        let lon = worldX / World.fullExtent * 360.0 - 180.0
        let lat = atan( sinh (Double.pi - (worldY / World.fullExtent) * 2 * Double.pi)) * (180.0 / Double.pi)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    static func mapPoint(scaledX : Double, scaledY : Double, downScale: Double) -> MapPoint{
        MapPoint(x: scaledX / downScale, y: scaledY / downScale)
    }
    
    static func mapPoint(scaledPoint: MapPoint, downScale: Double) -> MapPoint{
        mapPoint(scaledX: scaledPoint.x, scaledY: scaledPoint.y, downScale: downScale)
    }
    
    static func mapRect(scaledX : Double, scaledY : Double, scaledWidth: Double, scaledHeight: Double, downScale: Double) -> MapRect{
        MapRect(x: scaledX / downScale, y: scaledY / downScale, width: scaledWidth/downScale, height: scaledHeight/downScale)
    }
    
    static func mapRect(scaledRect: MapRect, downScale: Double) -> MapRect{
        mapRect(scaledX: scaledRect.minX, scaledY: scaledRect.minY, scaledWidth: scaledRect.width, scaledHeight: scaledRect.height, downScale: downScale)
    }
    
    static func coordinate(scaledX : Double, scaledY : Double, downScale: Double) -> CLLocationCoordinate2D {
        let mapPoint = mapPoint(scaledX: scaledX, scaledY: scaledY, downScale: downScale).normalizedPoint
        return mapPoint.coordinate
    }
    
    static func scaledExtent(downScale: Double) -> Double {
        fullExtent * downScale
    }
    
    static func scaledX(_ longitude: Double, downScale: Double) -> Double {
        round(projectedLongitude(longitude) * fullExtent * downScale)
    }
    
    static func scaledY(_ latitude: Double, downScale: Double) -> Double {
        round(projectedLatitude(latitude) * fullExtent * downScale)
    }
    
}
