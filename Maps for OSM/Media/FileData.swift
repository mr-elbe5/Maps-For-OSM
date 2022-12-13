/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

enum FileType: String, Codable{
    case audio
    case photo
    case image
    case video
}

class FileData : Equatable, Identifiable, Codable{
    
    static func == (lhs: FileData, rhs: FileData) -> Bool {
        lhs.fileName == rhs.fileName
    }
    
    
    private enum CodingKeys: CodingKey{
        case id
        case creationDate
        case fileName
    }
    
    var id: UUID
    var creationDate: Date
    
    var isNew = false
    
    var type : FileType{
        fatalError("not implemented")
    }
    
    var fileName : String {
        fatalError("not implemented")
    }
    
    var filePath : String{
        FileController.getPath(dirPath: FileController.privatePath,fileName: fileName)
    }
    
    var fileURL : URL{
        FileController.getURL(dirURL: FileController.privateURL,fileName: fileName)
    }
    
    init(isNew: Bool = false){
        self.isNew = isNew
        id = UUID()
        creationDate = Date()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        creationDate = try values.decode(Date.self, forKey: .creationDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(fileName, forKey: .fileName)
    }
    
    func getFile() -> Data?{
        let url = FileController.getURL(dirURL: FileController.privateURL,fileName: fileName)
        return FileController.readFile(url: url)
    }
    
    func saveFile(data: Data){
        if !fileExists(){
            let url = FileController.getURL(dirURL: FileController.privateURL,fileName: fileName)
            _ = FileController.saveFile(data: data, url: url)
        }
    }
    
    func fileExists() -> Bool{
        return FileController.fileExists(dirPath: FileController.privatePath, fileName: fileName)
    }
    
    func prepareDelete(){
        if FileController.fileExists(dirPath: FileController.privatePath, fileName: fileName){
            if !FileController.deleteFile(dirURL: FileController.privateURL, fileName: fileName){
                error("FileData could not delete file: \(fileName)")
            }
        }
    }
    
}

