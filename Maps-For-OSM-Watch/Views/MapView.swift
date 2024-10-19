//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct MapView: View {
        
    @State var locationStatus = LocationStatus.shared
    
    var body: some View {
        ZStack{
            if locationStatus.location != nil{
                TileView(tileData: TileData(zoom: locationStatus.zoom, tileX: locationStatus.tileX, tileY: locationStatus.tileY))
                    .assertImage()
                    .position(x: 0, y: 0)
                    .frame(width: 256, height: 256)
                TileView(tileData: TileData(zoom: locationStatus.zoom, tileX: locationStatus.tileX + 1, tileY: locationStatus.tileY))
                    .assertImage()
                    .position(x: 256, y: 0)
                    .frame(width: 256, height: 256)
                TileView(tileData: TileData(zoom: locationStatus.zoom, tileX: locationStatus.tileX, tileY: locationStatus.tileY + 1))
                    .assertImage()
                    .position(x: 0, y: 256)
                    .frame(width: 256, height: 256)
                TileView(tileData: TileData(zoom: locationStatus.zoom, tileX: locationStatus.tileX + 1, tileY: locationStatus.tileY + 1))
                    .assertImage()
                    .position(x: 256, y: 256)
                    .frame(width: 256, height: 256)
            }
        }
    }
    
}

#Preview {
    MapView()
}
