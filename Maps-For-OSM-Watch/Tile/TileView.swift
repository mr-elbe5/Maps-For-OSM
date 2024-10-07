//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct TileView: View {
    
    var tileData: TileData
    
    var body: some View {
        ZStack {
            Image(uiImage: tileData.image ?? UIImage(named: "gear.grey")!)
            Text("\(tileData.tileX), \(tileData.tileY)")
        }
        .frame(width: 256, height: 256)
        .border(.blue)
    }
    
}

#Preview {
    @Previewable var tileData = TileData(zoom: 16, tileX: 2, tileY: 3)
    TileView( tileData: tileData)
        .onAppear() {
            if tileData.image == nil {
                TileProvider.instance.assertTileImage(tile: tileData)
            }
        }
}
