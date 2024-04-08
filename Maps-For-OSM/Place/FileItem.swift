/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CloudKit

class FileItem : PlaceItem{
    
    private enum CodingKeys: CodingKey{
        case fileName
        case title
    }
    
    static var fileNameKey = "fileName"
    static var dataKey = "data"
    
    var title: String
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
    
    var fileRecordId : CKRecord.ID{
        get{
            CKRecord.ID(recordName: id.uuidString)
        }
    }
    
    var fileRecord: CKRecord{
        get{
            let record = CKRecord(recordType: CKContainer.fileType, recordID: fileRecordId)
            let data = FileController.readFile(url: fileURL)
            record[Selectable.idKey] = id.uuidString
            record[PlaceItem.placeIdKey] = place.id.uuidString
            record[PlaceItem.creationDateKey] = creationDate
            record[PlaceItem.changeDateKey] = changeDate
            record[FileItem.fileNameKey] = fileName
            record[FileItem.dataKey] = data
            return record
        }
    }
    
    override init(){
        fileName = ""
        title = ""
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileName = try values.decode(String.self, forKey: .fileName)
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
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
            if !FileController.saveFile(data: data, url: url){
                Log.error("file could not be saved at \(url)")
            }
        }
        else{
            Log.error("MediaFile exists \(fileName)")
        }
    }
    
    func fileExists() -> Bool{
        return FileController.fileExists(dirPath: FileController.mediaDirURL.path, fileName: fileName)
    }
    
    override func prepareDelete(){
        if FileController.fileExists(dirPath: FileController.mediaDirURL.path, fileName: fileName){
            if !FileController.deleteFile(dirURL: FileController.mediaDirURL, fileName: fileName){
                Log.error("FileItem could not delete file: \(fileName)")
            }
        }
    }
    
}

