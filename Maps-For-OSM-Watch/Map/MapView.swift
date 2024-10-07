//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct MapView: View, LocationManagerDelegate {
    
    @State var status = Status.instance
    @State var topLeftData = TileData()
    @State var topRightData = TileData()
    @State var bottomLeftData = TileData()
    @State var bottomRightData = TileData()
    @State var offsetX = 0.0
    @State var offsetY = 0.0
    
    var body: some View {
        TileView(tileData: topLeftData)
            .offset(x: offsetX, y: offsetY)
        TileView(tileData: topRightData)
            .offset(x: offsetX + 256, y: offsetY)
        TileView(tileData: bottomLeftData)
            .offset(x: offsetX, y: offsetY + 256)
        TileView(tileData: bottomRightData)
            .offset(x: offsetX + 256, y: offsetY + 256)
            .onAppear{
                locationChanged(LocationManager.startLocation)
            }
    }
    
    func locationChanged(_ location: CLLocation) {
        let coordinate = location.coordinate
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
        let worldDx = Int(worldPoint.x) % 256
        let worldDy = Int(worldPoint.y) % 256
        let dx = -(Double(worldDx) * zoomScaleFromWorld)
        let dy = -(Double(worldDy) * zoomScaleFromWorld)
        print("dx,dy \(dx), \(dy)")
        
        topLeftData = TileData(zoom: zoom, tileX: tileX, tileY: tileY)
        TileProvider.instance.assertTileImage(tile: topLeftData)
        topRightData = TileData(zoom: zoom, tileX: tileX + 1, tileY: tileY)
        TileProvider.instance.assertTileImage(tile: topRightData)
        bottomLeftData = TileData(zoom: zoom, tileX: tileX, tileY: tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomLeftData)
        bottomRightData = TileData(zoom: zoom, tileX: tileX + 1, tileY: tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomRightData)
        offsetX = Double(dx)
        offsetY = Double(dy)
    }
    
}

#Preview {
    MainView()
}
