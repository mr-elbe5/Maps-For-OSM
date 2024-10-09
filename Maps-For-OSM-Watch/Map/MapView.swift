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
        let data = TileAndOffsetData(location: location, status: status)
        
        topLeftData.update(zoom: status.zoom, tileX: data.tileX, tileY: data.tileY)
        TileProvider.instance.assertTileImage(tile: topLeftData)
        topRightData.update(zoom: status.zoom, tileX: data.tileX + 1, tileY: data.tileY)
        TileProvider.instance.assertTileImage(tile: topRightData)
        bottomLeftData.update(zoom: status.zoom, tileX: data.tileX, tileY: data.tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomLeftData)
        bottomRightData.update(zoom: status.zoom, tileX: data.tileX + 1, tileY: data.tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomRightData)
        offsetX = data.offsetX + 49
        offsetY = data.offsetY + 62
    }
    
}

#Preview {
    MapView()
}
