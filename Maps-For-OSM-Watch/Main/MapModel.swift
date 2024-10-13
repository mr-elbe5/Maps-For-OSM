//
//  MapModel.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 12.10.24.
//

import Foundation
import CoreLocation

@Observable class MapModel: NSObject{
    
    var coordinate: CLLocationCoordinate2D = LocationManager.startLocation.coordinate
    var altitude: CLLocationDistance = LocationManager.startLocation.altitude
    
    var zoom = 16
    var tileX: Int = 0
    var tileY: Int = 0
    
    var mapOffsetX: CGFloat = 0
    var mapOffsetY: CGFloat = 0
    
    func update(coordinate: CLLocationCoordinate2D){
        print("updating to coordinate \(coordinate)")
        print("frame is \(Status.instance.mainViewFrame)")
        let coordinate = CLLocationCoordinate2D(latitude: 53.5419, longitude: 9.6831)
        print(coordinate)
        let zoomScaleFromWorld = World.zoomScaleFromWorld(to: zoom)
        print("zoom scale \(zoomScaleFromWorld)")
        let x = World.scaledX(coordinate.longitude, downScale: zoomScaleFromWorld)
        print("x: \(x)")
        let y = World.scaledY(coordinate.latitude, downScale: zoomScaleFromWorld)
        print("y: \(y)")
        tileX = Int(floor((x  - Status.instance.mainViewFrame.width/2) / World.tileExtent))
        tileY = Int(floor((y  - Status.instance.mainViewFrame.height/2) / World.tileExtent))
        print("tileX, tileY \(tileX), \(tileY)")
        
        let tileXOffset = Double(tileX)*World.tileExtent
        let tileYOffset = Double(tileY)*World.tileExtent
        print("tileXOff, tileYOff \(tileXOffset), \(tileYOffset)")
        
        let innerOffsetX = tileXOffset - x
        let innerOffsetY = tileYOffset - y
        
        print("offsetX,offsetY \(innerOffsetX), \(innerOffsetY)")
        
        // offset of center
        mapOffsetX = innerOffsetX + 256
        mapOffsetY = innerOffsetY + 256
        
    }
    
}