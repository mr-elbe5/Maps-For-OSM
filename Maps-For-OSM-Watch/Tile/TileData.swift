//
//  TileData.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 07.10.24.
//

import Foundation
import SwiftUI

@Observable class TileData{
    
    var zoom: Int = World.maxZoom
    var tileX: Int = 0
    var tileY: Int = 0
    var imageData: Data? = nil
    
    public var fileUrl: URL{
        FileManager.tilesDirURL.appendingPathComponent("\(zoom)-\(tileX)-\(tileY).png")
    }
    
    init(){
    }
    
    init(zoom: Int, tileX: Int, tileY: Int){
        self.zoom = zoom
        self.tileX = tileX
        self.tileY = tileY
    }
    
    func update(zoom: Int, tileX: Int, tileY: Int){
        self.zoom = zoom
        self.tileX = tileX
        self.tileY = tileY
    }
    
}
