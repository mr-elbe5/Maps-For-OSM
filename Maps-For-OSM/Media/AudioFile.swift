/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class AudioFile : MediaFile{
    
    enum AudioCodingKeys: String, CodingKey {
        case title
        case time
    }
    
    var time: Double
    
    override var type : MediaType{
        get{
            return .audio
        }
    }

    override init(){
        time = 0.0
        super.init()
        fileName = "audio_\(id).m4a"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AudioCodingKeys.self)
        time = try values.decode(Double.self, forKey: .time)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: AudioCodingKeys.self)
        try container.encode(time, forKey: .time)
    }
    
}
