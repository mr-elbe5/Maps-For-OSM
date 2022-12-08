/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class AudioData : FileData{
    
    enum AudioCodingKeys: String, CodingKey {
        case title
        case time
    }
    
    var title: String = ""
    var time: Double = 0.0
    
    override var type : FileType{
        get{
            return .audio
        }
    }

    override var fileName : String {
        get{
            return "audio_\(creationDate.fileDate()).m4a"
        }
        set{
            print("error: setting file name not implemented for AudioItemData")
        }
    }
    
    init(){
        time = 0.0
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AudioCodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        time = try values.decode(Double.self, forKey: .time)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: AudioCodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(time, forKey: .time)
    }
    
    override func isComplete() -> Bool{
        return fileExists()
    }
    
    override func addActiveFileNames( to fileNames: inout Array<String>){
        fileNames.append(fileName)
    }
    
}
