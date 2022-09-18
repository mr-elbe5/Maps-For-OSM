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
        
        print("maxZoom = \(World.maxZoom)")
        print("worldSize = \(World.mapSize.string)")
        
        let mapPoint = MapPoint(coordinate)
        print("coordinate = \(coordinate.shortString)")
        print("mapPoint = \(mapPoint.string)")
        print("mappoint coordinate = \(mapPoint.coordinate.shortString)")
        
        //18/138123/84731
        let tile = MapTile(zoom: 18, x: 138123, y: 84732)
        print("tile mapRect = \(tile.rectInZoomedWorld.string)")
        let worldRect = tile.rectInWorld
        print("worldRect = \(worldRect.string)")
        print("tile origin = \(worldRect.origin.coordinate.shortString)")
    }
    
    static func testMapView(mapView: MapView){
        print("mapView at scale \(mapView.scrollView.zoomScale) -------")
        //print("bounds = \(mapView.scrollView.bounds.debugDescription)")
        //print("visible size = \(mapView.scrollView.visibleSize.debugDescription)")
        //print("content size = \(mapView.scrollView.contentSize.debugDescription)")
        print("zoom = \(mapView.zoom)")
        //let zoomScale = World.zoomScale(at: mapView.zoom)
        //print("zoomScale = \(zoomScale)")
        //let zoomScaleTo = World.zoomScaleToWorld(from: mapView.zoom)
        //print("zoomScaleToWorld = \(zoomScaleTo)")
        //let zoomScaleFrom = World.zoomScaleFromWorld(to: mapView.zoom)
        //print("zoomScaleToWorld*zoomScaleFromWorld = \(zoomScaleTo*zoomScaleFrom)")
        //print("zoomLevelFromScale = \(World.zoomLevelFromScale(scale: zoomScale))")
        print("visibleMapRect = \(mapView.scrollView.visibleMapRect.string)")
        print("screenCenterMapPoint = \(mapView.scrollView.screenCenterMapPoint.string)")
        print("screenCenterMapPoint.coordinate = \(mapView.scrollView.screenCenterMapPoint.coordinate.shortString)")
        print("scaledWorldSize = \(mapView.scrollView.scaledWorldSize)")
        
        print("screenCenter = \(mapView.scrollView.screenCenter)")
        print("screenCenterPoint = \(mapView.scrollView.mapPoint(screenPoint: mapView.scrollView.screenCenter).string)")
        print("screenCenterCoordinate = \(mapView.scrollView.mapPoint(screenPoint: mapView.scrollView.screenCenter).coordinate.shortString)")
        
        print("centerScreenPoint = \(mapView.scrollView.screenPoint(coordinate: coordinate))")
        
    }
    
}
