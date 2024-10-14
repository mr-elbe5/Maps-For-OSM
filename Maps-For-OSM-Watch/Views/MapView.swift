//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct MapView: View {
        
    @Binding var appStatus: AppStatus
    @Binding var mapStatus: MapStatus
    
    var body: some View {
        ZStack{
            TileView(tileData: TileData(zoom: mapStatus.zoom, tileX: mapStatus.tileX, tileY: mapStatus.tileY))
                .assertImage()
                .position(x: 0, y: 0)
                .frame(width: 256, height: 256)
            TileView(tileData: TileData(zoom: mapStatus.zoom, tileX: mapStatus.tileX + 1, tileY: mapStatus.tileY))
                .assertImage()
                .position(x: 256, y: 0)
                .frame(width: 256, height: 256)
            TileView(tileData: TileData(zoom: mapStatus.zoom, tileX: mapStatus.tileX, tileY: mapStatus.tileY + 1))
                .assertImage()
                .position(x: 0, y: 256)
                .frame(width: 256, height: 256)
            TileView(tileData: TileData(zoom: mapStatus.zoom, tileX: mapStatus.tileX + 1, tileY: mapStatus.tileY + 1))
                .assertImage()
                .position(x: 256, y: 256)
                .frame(width: 256, height: 256)
        }
    }
    
}

#Preview {
    @Previewable @State var appStatus = AppStatus()
    @Previewable @State var mapStatus = MapStatus()
    MapView(appStatus: $appStatus, mapStatus: $mapStatus)
}
