//
//  TileData.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 07.10.24.
//

import Foundation
import SwiftUI

@Observable class TileData: Equatable{
    
    static func == (lhs: TileData, rhs: TileData) -> Bool {
        lhs.zoom == rhs.zoom && lhs.tileX == rhs.tileX && lhs.tileY == rhs.tileY
    }
    
    var zoom: Int = World.maxZoom
    var tileX: Int = 0
    var tileY: Int = 0
    var imageData: Data? = nil
    
    var fileUrl: URL{
        FileManager.tileDirURL.appendingPathComponent("\(zoom)-\(tileX)-\(tileY).png")
    }
    
    init(zoom: Int, tileX: Int, tileY: Int){
        self.zoom = zoom
        self.tileX = tileX
        self.tileY = tileY
    }
    
    func getDescription() -> String{
        "\(zoom)-\(tileX)-\(tileY)"
    }
    
}
