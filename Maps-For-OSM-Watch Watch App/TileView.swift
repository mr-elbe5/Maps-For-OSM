//
//  MapView.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import SwiftUI

struct TileView: View {
    
    var tileX: Int
    var tileY: Int
    
    var body: some View {
        ZStack {
            Color(.yellow)
            Text("\(tileX), \(tileY)")
        }
        .frame(width: 256, height: 256)
        .border(.blue)
    }
    
}

#Preview {
    TileView( tileX: 2, tileY: 3)
}
