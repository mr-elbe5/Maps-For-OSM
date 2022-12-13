/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias FileList = Array<FileListData>
    
extension FileList{
    
    mutating func append(_ file: FileData){
        let listData = FileListData(file: file)
        append(listData)
    }
    
    mutating func remove(_ file: FileData){
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

class FileListData : Identifiable, Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    var type : FileType
    var data : FileData
    
    init(file: FileData){
        self.type = file.type
        self.data = file
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(FileType.self, forKey: .type)
        switch type{
        case .audio:
            data = try values.decode(AudioData.self, forKey: .data)
            break
        case .photo:
            data = try values.decode(PhotoData.self, forKey: .data)
            break
        case .image:
            data = try values.decode(ImageData.self, forKey: .data)
            break
        case .video:
            data = try values.decode(VideoData.self, forKey: .data)
            break
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}

