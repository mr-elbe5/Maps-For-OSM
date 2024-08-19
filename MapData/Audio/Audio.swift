/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import E5Data

open class Audio : FileItem{
    
    public enum AudioCodingKeys: String, CodingKey {
        case time
    }
    
    public var time: Double
    
    override public var type : LocatedItemType{
        get{
            return .audio
        }
    }
    
    override public init(){
        time = 0.0
        super.init()
        fileName = "audio_\(id).m4a"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AudioCodingKeys.self)
        time = try values.decode(Double.self, forKey: .time)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: AudioCodingKeys.self)
        try container.encode(time, forKey: .time)
    }
    
}
