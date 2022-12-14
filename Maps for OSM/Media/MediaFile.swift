/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

enum MediaType: String, Codable{
    case audio
    case image
    case video
}

class MediaFile : Equatable, Identifiable, Codable{
    
    static func == (lhs: MediaFile, rhs: MediaFile) -> Bool {
        lhs.fileName == rhs.fileName
    }
    
    
    private enum CodingKeys: CodingKey{
        case id
        case creationDate
        case fileName
        case title
    }
    
    var id: UUID
    var creationDate: Date
    var title: String
    
    var type : MediaType{
        fatalError("not implemented")
    }
    
    var fileName : String
    
    var filePath : String{
        FileController.getPath(dirPath: FileController.mediaDirURL.path,fileName: fileName)
    }
    
    var fileURL : URL{
        FileController.getURL(dirURL: FileController.mediaDirURL,fileName: fileName)
    }
    
    init(){
        id = UUID()
        creationDate = Date()
        fileName = ""
        title = ""
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        creationDate = try values.decode(Date.self, forKey: .creationDate)
        fileName = try values.decode(String.self, forKey: .fileName)
        title = try values.decode(String.self, forKey: .title)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(title, forKey: .title)
    }
    
    func getFile() -> Data?{
        let url = FileController.getURL(dirURL: FileController.mediaDirURL,fileName: fileName)
        debug("MediaFile getting data from \(url.path)")
        return FileController.readFile(url: url)
    }
    
    func saveFile(data: Data){
        if !fileExists(){
            let url = FileController.getURL(dirURL: FileController.mediaDirURL,fileName: fileName)
            _ = FileController.saveFile(data: data, url: url)
        }
    }
    
    func fileExists() -> Bool{
        return FileController.fileExists(dirPath: FileController.mediaDirURL.path, fileName: fileName)
    }
    
    func prepareDelete(){
        if FileController.fileExists(dirPath: FileController.mediaDirURL.path, fileName: fileName){
            if !FileController.deleteFile(dirURL: FileController.mediaDirURL, fileName: fileName){
                error("FileData could not delete file: \(fileName)")
            }
        }
    }
    
}

