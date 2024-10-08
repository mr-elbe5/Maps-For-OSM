//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct TileView: View {
    
    @Bindable var tileData: TileData
    
    var body: some View {
        ZStack {
            if let imageData = tileData.imageData{
                if let image = UIImage(data: imageData){
                    Image(uiImage: image)
                }
            }
            else{
                Image(uiImage: UIImage(named: "gear.grey")!)
            }
        }
        .frame(width: 256, height: 256)
    }
    
}

#Preview {
    @Previewable var tileData = TileData(zoom: 16, tileX: 2, tileY: 3)
    TileView( tileData: tileData)
        .onAppear() {
            if tileData.imageData == nil {
                TileProvider.instance.assertTileImage(tile: tileData)
            }
        }
}
