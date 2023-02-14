/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

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
