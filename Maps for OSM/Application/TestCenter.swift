//
//  TestCenter.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation
import CoreLocation

struct TestCenter{
    
    static var coordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    
    static func testWorld(){
        
        info("maxZoom = \(World.maxZoom)")
        info("worldSize = \(World.mapSize.string)")
        info("equatorInMeters = \(World.equatorInMeters)")
        info("worldEquatorMetersPerPixel = \(World.equatorInMeters/World.tileExtent)")
        
        let mapPoint = MapPoint(coordinate)
        info("coordinate = \(coordinate.shortString)")
        info("mapPoint = \(mapPoint.string)")
        info("mappoint coordinate = \(mapPoint.coordinate.shortString)")
        
        //18/138123/84731
        let tile = MapTile(zoom: 18, x: 138123, y: 84732)
        info("tile mapRect = \(tile.rectInZoomedWorld.string)")
        let worldRect = tile.rectInWorld
        info("worldRect = \(worldRect.string)")
        info("tile origin = \(worldRect.origin.coordinate.shortString)")
    }
    
    static func testMapView(mapView: MapView){
        info("mapView at scale \(mapView.scrollView.zoomScale) -------")
        info("bounds = \(mapView.scrollView.bounds.debugDescription)")
        info("visible size = \(mapView.scrollView.visibleSize.debugDescription)")
        info("content size = \(mapView.scrollView.contentSize.debugDescription)")
        info("zoom = \(mapView.zoom)")
        let zoomScale = World.zoomScale(at: mapView.zoom)
        info("zoomScale = \(zoomScale)")
        let zoomScaleTo = World.zoomScaleToWorld(from: mapView.zoom)
        info("zoomScaleToWorld = \(zoomScaleTo)")
        let zoomScaleFrom = World.zoomScaleFromWorld(to: mapView.zoom)
        info("zoomScaleToWorld*zoomScaleFromWorld = \(zoomScaleTo*zoomScaleFrom)")
        info("zoomLevelFromScale = \(World.zoomLevelFromScale(scale: zoomScale))")
        info("visibleMapRect = \(mapView.scrollView.visibleMapRect.string)")
        info("screenCenterMapPoint = \(mapView.scrollView.screenCenterMapPoint.string)")
        info("screenCenterMapPoint.coordinate = \(mapView.scrollView.screenCenterMapPoint.coordinate.shortString)")
        
        info("World.scaledExtent = \(World.scaledExtent(downScale: mapView.scrollView.zoomScale))")
        
        info("screenCenter = \(mapView.scrollView.screenCenter)")
        info("screenCenterPoint = \(mapView.scrollView.mapPoint(screenPoint: mapView.scrollView.screenCenter).string)")
        info("screenCenterCoordinate = \(mapView.scrollView.mapPoint(screenPoint: mapView.scrollView.screenCenter).coordinate.shortString)")
        
        info("centerScreenPoint = \(mapView.scrollView.screenPoint(coordinate: coordinate))")
        
        info("------- new ------")
        info("tileX = \(World.tileX(coordinate.longitude))")
        info("tileX at 18 = \(World.tileX(coordinate.longitude, withZoom: 18))")
        info("tileY = \(World.tileY(coordinate.latitude))")
        info("tileY at 18 = \(World.tileY(coordinate.latitude, withZoom: 18))")
        
        let scale = World.zoomScaleFromWorld(to: 18)
        info("worldX = \(World.worldX(coordinate.longitude))")
        info("scaledX at 18 = \(World.scaledX(coordinate.longitude, downScale: scale))")
        info("worldY = \(World.worldY(coordinate.latitude))")
        info("scaledY at 18 = \(World.scaledY(coordinate.latitude, downScale: scale))")
        
        let mapPoint = MapPoint(coordinate)
        info("coordinate = \(coordinate.shortString)")
        info("mapPoint = \(mapPoint.string)")
        info("coordinateAtWorld = \(World.coordinate(worldX : mapPoint.x, worldY : mapPoint.y))")
        
        let worldScale = mapView.scrollView.zoomScale
        info("worldScale = \(worldScale)")
        let scaledWorldExtent = World.scaledExtent(downScale: worldScale)
        info("scaledWorldExtent = \(scaledWorldExtent)")
        info("contentHeight = \(mapView.scrollView.contentSize.height)")
        let scaledMapPoint = mapView.scrollView.contentPoint(screenPoint: mapView.scrollView.screenCenter)
        info("scaledMapPoint = \(scaledMapPoint)")
        info("coordinateAtScaledWorld = \(World.coordinate(scaledX : scaledMapPoint.x, scaledY : scaledMapPoint.y, downScale: worldScale))")
    }
    
}
