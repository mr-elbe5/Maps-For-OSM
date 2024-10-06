//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct MapView: View {
    
    @State var status: Status = Status.instance
    @State var locationManager: LocationManager = LocationManager.instance
    
    var body: some View {
        if let mapInfo = getMapInfo() {
            TileView(tileX: mapInfo.tileX, tileY: mapInfo.tileY)
                .offset(x: CGFloat(mapInfo.dx), y: CGFloat(mapInfo.dy))
            TileView(tileX: mapInfo.tileX + 1, tileY: mapInfo.tileY)
                .offset(x: CGFloat(mapInfo.dx + 256), y: CGFloat(mapInfo.dy))
            TileView(tileX: mapInfo.tileX, tileY: mapInfo.tileY + 1)
                .offset(x: CGFloat(mapInfo.dx), y: CGFloat(mapInfo.dy + 256))
            TileView(tileX: mapInfo.tileX + 1, tileY: mapInfo.tileY + 1)
                .offset(x: CGFloat(mapInfo.dx + 256), y: CGFloat(mapInfo.dy + 256))
        }
        
    }
    
    func getMapInfo() -> MapInfo? {
        let coordinate = locationManager.location.coordinate
        print(coordinate)
        let screenCenter = status.screenCenter
        print("screen center \(screenCenter)")
        let zoom = status.zoom
        print("zoom \(zoom)")
        let zoomScaleFromWorld = World.zoomScaleFromWorld(to: zoom)
        print("zoom scale \(zoomScaleFromWorld)")
        let x = World.scaledX(coordinate.longitude, downScale: zoomScaleFromWorld)
        let y = World.scaledY(coordinate.latitude, downScale: zoomScaleFromWorld)
        let worldSize = World.scaledExtent(downScale: zoomScaleFromWorld)
        print("world size \(worldSize)")
        let worldPoint = CGPoint(x: x, y: y)
        print("world point \(worldPoint)")
        let tileX = Int(floor(worldPoint.x / 256.0))
        let tileY = Int(floor(worldPoint.y / 256.0))
        print("tile \(tileX), \(tileY)")
        let dx = -Int(worldPoint.x) % 256
        let dy = -Int(worldPoint.y) % 256
        print("dx,dy \(dx), \(dy)")
        
        let mapInfo = MapInfo(tileX: tileX, tileY: tileY, dx: dx, dy: dy)
        return mapInfo
    }
    
}

struct MapInfo{
    
    var tileX: Int
    var tileY: Int
    var dx: Int
    var dy: Int
    
}

#Preview {
    MainView()
}
