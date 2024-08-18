/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5MapData

class MacPreferences: Preferences {
    
    static var macshared: MacPreferences{
        get{
            Preferences.shared as! MacPreferences
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case gridSizeFactorIndex
    }
    
    var gridSizeFactorIndex: Int = 2
    
    override init(){
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gridSizeFactorIndex = try values.decodeIfPresent(Int.self, forKey: .gridSizeFactorIndex) ?? 2
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gridSizeFactorIndex, forKey: .gridSizeFactorIndex)
    }
    
}
