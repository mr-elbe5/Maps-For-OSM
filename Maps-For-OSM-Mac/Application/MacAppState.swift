/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation


class MacAppState: AppState {
    
    enum CodingKeys: String, CodingKey {
        case viewType
    }
    
    var viewType: MainViewType = .map
    
    override init(){
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let type = try values.decodeIfPresent(Int.self, forKey: .viewType){
            viewType = MainViewType(rawValue: type) ?? .map
        }
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(viewType.rawValue, forKey: .viewType)
    }
    
}
