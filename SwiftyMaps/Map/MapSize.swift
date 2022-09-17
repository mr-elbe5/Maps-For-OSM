//
//  MapSize.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 15.09.22.
//

import Foundation

// size in the world at full scale in pixels
class MapSize{
    
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
    
    var cgSize : CGSize{
        CGSize(width: width, height: height)
    }
    
    var string : String{
        "height: \(height), width: \(width)"
    }
    
}
