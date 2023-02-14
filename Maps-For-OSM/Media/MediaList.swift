/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias MediaList = Array<MediaData>
    
extension MediaList{
    
    mutating func append(_ file: MediaFile){
        let listData = MediaData(file: file)
        append(listData)
    }
    
    mutating func remove(_ file: MediaFile){
        for idx in 0..<self.count{
            if self[idx].data == file{
                FileController.deleteFile(url: file.fileURL)
                self.remove(at: idx)
                return
            }
        }
    }
    
    mutating func removeAllFiles(){
        for file in self{
            FileController.deleteFile(url: file.data.fileURL)
        }
        removeAll()
    }
    
}

class MediaData : Identifiable, Codable{
    
    static func areInIncreasingDateOrder(media1: MediaData, media2: MediaData) throws -> Bool{
        return media2.data.creationDate >= media1.data.creationDate
    }
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    var type : MediaType
    var data : MediaFile
    
    init(file: MediaFile){
        self.type = file.type
        self.data = file
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(MediaType.self, forKey: .type)
        switch type{
        case .audio:
            data = try values.decode(AudioFile.self, forKey: .data)
            break
        case .image:
            data = try values.decode(ImageFile.self, forKey: .data)
            break
        case .video:
            data = try values.decode(VideoFile.self, forKey: .data)
            break
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}

