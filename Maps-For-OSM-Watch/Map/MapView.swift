//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct MapView: View {
        
    @State var topLeftData = TileData()
    @State var topRightData = TileData()
    @State var bottomLeftData = TileData()
    @State var bottomRightData = TileData()
    @Binding var offsetX: CGFloat
    @Binding var offsetY: CGFloat
    @Binding var direction: CLLocationDirection
    var size : CGSize = .zero
    
    var body: some View {
        ZStack{
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
            Text("\(size)")
                .foregroundColor(.black)
        }
        .onAppear(){
            locationChanged(LocationManager.startLocation)
            LocationManager.instance.locationDelegate = self
        }
        .onChange(of: topLeftData){
            print("topleft: \(topLeftData)")
        }
    }
    
}

extension MapView : LocationManagerDelegate {
    
    func locationChanged(_ location: CLLocation) {
        print("location changed")
        let data = TileAndOffsetData(location: location, zoom: Status.instance.zoom, screenCenter: CGPoint(x: size.width/2, y: size.height/2))
        
        topLeftData.update(zoom: Status.instance.zoom, tileX: data.tileX, tileY: data.tileY)
        TileProvider.instance.assertTileImage(tile: topLeftData)
        topRightData.update(zoom: Status.instance.zoom, tileX: data.tileX + 1, tileY: data.tileY)
        TileProvider.instance.assertTileImage(tile: topRightData)
        bottomLeftData.update(zoom: Status.instance.zoom, tileX: data.tileX, tileY: data.tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomLeftData)
        bottomRightData.update(zoom: Status.instance.zoom, tileX: data.tileX + 1, tileY: data.tileY + 1)
        TileProvider.instance.assertTileImage(tile: bottomRightData)
        offsetX = data.offsetX
        offsetY = data.offsetY
    }
    
    func directionChanged(_ direction: CLLocationDirection) {
        self.direction = direction
    }
    
}

#Preview {
    @Previewable @State var offsetX:CGFloat = 0
    @Previewable @State var offsetY:CGFloat = 0
    @Previewable @State var currentDirection: CLLocationDirection = 45
    MapView(offsetX: $offsetX, offsetY: $offsetY, direction: $currentDirection)
}
