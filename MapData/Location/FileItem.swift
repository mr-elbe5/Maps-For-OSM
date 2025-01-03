/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import CloudKit

class FileItem : LocatedItem{
    
    static var recordMetaKeys = ["uuid"]
    static var recordDataKeys = ["uuid", "asset"]
    
    private enum CodingKeys: CodingKey{
        case fileName
        case title
    }
    
    var comment: String
    var fileName : String
    
    var filePath : String{
        if fileName.isEmpty{
            Log.error("File has no name")
            return ""
        }
        return FileManager.mediaDirURL.path.appendingPathComponent(fileName)
    }
    
    var fileURL : URL{
        if fileName.isEmpty{
            Log.error("File has no name")
        }
        return FileManager.mediaDirURL.appendingPathComponent(fileName)
    }
    
    var fileRecordId : CKRecord.ID{
        get{
            CKRecord.ID(recordName: id.uuidString)
        }
    }
    
    var fileRecord: CKRecord{
        get{
            let record = CKRecord(recordType: CKRecord.fileType, recordID: fileRecordId)
            let asset = CKAsset(fileURL: fileURL)
            record["uuid"] = id.uuidString
            record["asset"] = asset
            return record
        }
    }
    
    override init(){
        fileName = ""
        comment = ""
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileName = try values.decode(String.self, forKey: .fileName)
        comment = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(comment, forKey: .title)
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
        let url = FileManager.mediaDirURL.appendingPathComponent(fileName)
        return FileManager.default.readFile(url: url)
    }
    
    func saveFile(data: Data){
        if !fileExists(){
            let url = FileManager.mediaDirURL.appendingPathComponent(fileName)
            if !FileManager.default.saveFile(data: data, url: url){
                Log.error("file could not be saved at \(url)")
            }
        }
        else{
            Log.error("MediaFile exists \(fileName)")
        }
    }
    
    func fileExists() -> Bool{
        return FileManager.default.fileExists(dirPath: FileManager.mediaDirURL.path, fileName: fileName)
    }
    
    override func prepareDelete(){
        if FileManager.default.fileExists(dirPath: FileManager.mediaDirURL.path, fileName: fileName){
            if !FileManager.default.deleteFile(dirURL: FileManager.mediaDirURL, fileName: fileName){
                Log.error("FileItem could not delete file: \(fileName)")
            }
        }
    }
    
}

typealias FileItemList = Array<FileItem>

