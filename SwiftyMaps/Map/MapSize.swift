//
//  MapSize.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 15.09.22.
//

import Foundation

// size in the world at full scale in pixels
class MapSize{
    
    static let maxZoom : Int = 20
    static let tileExtent : Double = 256.0
    static let worldExtent : Double = pow(2,Double(maxZoom))*tileExtent
    static let equatorInMeters : CGFloat = 40075016.686
    static let world = MapSize(width: worldExtent, height: worldExtent)
    
    var height: Double
    var width: Double
    
    init(){
        width = 0
        height = 0
    }
    
    init(width: Double, height: Double){
        self.width = width
        self.height = height
    }
    
    var string : String{
        "height: \(height), width: \(width)"
    }
    
}
