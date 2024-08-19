/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

open class Video : FileItem{
    
    enum VideoCodingKeys: String, CodingKey {
        case time
    }
    
    public var time: Double = 0.0
    
    override public var type : LocatedItemType{
        get{
            return .video
        }
    }
    
    override public init(){
        time = 0.0
        super.init()
        fileName = "video_\(id).mp4"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: VideoCodingKeys.self)
        time = try values.decodeIfPresent(Double.self, forKey: .time) ?? 0.0
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VideoCodingKeys.self)
        try container.encode(time, forKey: .time)
    }
    
}




