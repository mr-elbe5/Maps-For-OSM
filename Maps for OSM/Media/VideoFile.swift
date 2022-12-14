/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class VideoFile : MediaFile{
    
    enum VideoCodingKeys: String, CodingKey {
        case title
        case time
    }
    
    var time: Double = 0.0
    
    override var type : MediaType{
        get{
            return .video
        }
    }

    override var fileName : String {
        get{
            return "video\(creationDate.fileDate()).mp4"
        }
        set{
            error("VideoDatasetting file name not implemented")
        }
    }
    
    override init(){
        time = 0.0
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: VideoCodingKeys.self)
        time = try values.decodeIfPresent(Double.self, forKey: .time) ?? 0.0
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VideoCodingKeys.self)
        try container.encode(time, forKey: .time)
    }
    
}

