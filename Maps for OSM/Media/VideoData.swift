/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class VideoData : FileData{
    
    enum VideoCodingKeys: String, CodingKey {
        case title
        case time
    }
    
    var title: String = ""
    var time: Double = 0.0
    
    override var type : FileType{
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
    
    init(){
        time = 0.0
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: VideoCodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        time = try values.decodeIfPresent(Double.self, forKey: .time) ?? 0.0
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VideoCodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(time, forKey: .time)
    }
    
}

