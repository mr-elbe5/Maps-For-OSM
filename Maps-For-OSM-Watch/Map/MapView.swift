//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct MapView: View {
        
    @Binding var model: MapModel
    
    var body: some View {
        ZStack{
            TileView(tileData: TileData(zoom: Status.instance.zoom, tileX: model.tileX, tileY: model.tileY))
                .assertImage()
                .position(x: 0, y: 0)
                .frame(width: 256, height: 256)
            TileView(tileData: TileData(zoom: Status.instance.zoom, tileX: model.tileX + 1, tileY: model.tileY))
                .assertImage()
                .position(x: 256, y: 0)
                .frame(width: 256, height: 256)
            TileView(tileData: TileData(zoom: Status.instance.zoom, tileX: model.tileX, tileY: model.tileY + 1))
                .assertImage()
                .position(x: 0, y: 256)
                .frame(width: 256, height: 256)
            TileView(tileData: TileData(zoom: Status.instance.zoom, tileX: model.tileX + 1, tileY: model.tileY + 1))
                .assertImage()
                .position(x: 256, y: 256)
                .frame(width: 256, height: 256)
        }
    }
    
}

#Preview {
    @Previewable @State var model = MapModel()
    MapView(model: $model)
}
