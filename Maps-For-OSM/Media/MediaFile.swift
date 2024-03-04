/*
 Maps For OSM
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
        case localIdentifier
        case title
    }
    
    var id: UUID
    var creationDate: Date
    var localIdentifier: String
    var title: String
    
    var type : MediaType{
        fatalError("not implemented")
    }
    
    var fileName : String
    
    var filePath : String{
        if fileName.isEmpty{
            Log.error("MediaFile file has no name")
            return ""
        }
        return FileController.getPath(dirPath: FileController.mediaDirURL.path,fileName: fileName)
    }
    
    var fileURL : URL{
        if fileName.isEmpty{
            Log.error("MediaFile file has no name")
        }
        return FileController.getURL(dirURL: FileController.mediaDirURL,fileName: fileName)
    }
    
    init(){
        id = UUID()
        creationDate = Date()
        fileName = ""
        localIdentifier = ""
        title = ""
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        creationDate = try values.decode(Date.self, forKey: .creationDate)
        fileName = try values.decode(String.self, forKey: .fileName)
        localIdentifier = try values.decode(String.self, forKey: .localIdentifier)
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(localIdentifier, forKey: .localIdentifier)
        try container.encode(title, forKey: .title)
    }
    
    func setFileNameFromURL(_ url: URL){
        var name = url.lastPathComponent
        //Log.debug("file name from url is \(name)")
        fileName = name
        if fileExists(){
            Log.info("cannot use file name \(fileName)")
            var count = 1
            var ext = ""
            if let pntPos = name.lastIndex(of: "."){
                ext = String(name[pntPos...])
                name = String(name[..<pntPos])
            }
            do{
                fileName = "\(name)(\(count))\(ext)"
                if !fileExists(){
                    Log.info("new file name is \(fileName)")
                    return
                }
                count += 1
            }
        }
    }
    
    func getFile() -> Data?{
        let url = FileController.getURL(dirURL: FileController.mediaDirURL,fileName: fileName)
        return FileController.readFile(url: url)
    }
    
    func saveFile(data: Data){
        if !fileExists(){
            let url = FileController.getURL(dirURL: FileController.mediaDirURL,fileName: fileName)
            _ = FileController.saveFile(data: data, url: url)
        }
        else{
            Log.error("MediaFile exists \(fileName)")
        }
    }
    
    func fileExists() -> Bool{
        return FileController.fileExists(dirPath: FileController.mediaDirURL.path, fileName: fileName)
    }
    
    func prepareDelete(){
        if FileController.fileExists(dirPath: FileController.mediaDirURL.path, fileName: fileName){
            if !FileController.deleteFile(dirURL: FileController.mediaDirURL, fileName: fileName){
                Log.error("FileData could not delete file: \(fileName)")
            }
        }
    }
    
}

