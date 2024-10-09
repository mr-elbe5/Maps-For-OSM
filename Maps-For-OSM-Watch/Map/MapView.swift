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
    @State var offsetX: CGFloat = 0
    @State var offsetY: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .center){
            TileView(tileData: topLeftData)
                .position(x: 0, y: 0)
                .frame(width: 256, height: 256)
            TileView(tileData: topRightData)
                .position(x: 256, y: 0)
                .frame(width: 256, height: 256)
            TileView(tileData: bottomLeftData)
                .position(x: 0, y: 256)
                .frame(width: 256, height: 256)
            TileView(tileData: bottomRightData)
                .position(x: 256, y: 256)
                .frame(width: 256, height: 256)
        }
        .offset(CGSize(width: offsetX, height: offsetY))
        .onAppear{
            locationChanged(LocationManager.startLocation)
        }
    }
    
    func locationChanged(_ location: CLLocation) {
        let data = TileAndOffsetData(location: location, zoom: status.zoom, screenCenter: AppStatics.screenCenter)
        
        topLeftData.update(zoom: status.zoom, tileX: data.tileX, tileY: data.tileY)
        TileProvider.instance.assertTileImage(tile: topLeftData)
        topRightData.update(zoom: status.zoom, tileX: data.tileX + 1, tileY: data.tileY)
        TileProvider.instance.assertTileImage(tile: topRightData)
        bottomLeftData.update(zoom: status.zoom, tileX: data.tileX, tileY: data.tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomLeftData)
        bottomRightData.update(zoom: status.zoom, tileX: data.tileX + 1, tileY: data.tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomRightData)
        offsetX = -data.offsetX
        offsetY = -data.offsetY
    }
    
}

#Preview {
    MapView()
}
