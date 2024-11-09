/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class IdProvider : Codable{
    
    static var storeKey = "idProvider"
    
    static var minNewId = 1000000
    
    static var shared = IdProvider()
    
    static func load(){
        if let data: IdProvider = FileManager.default.readJsonFile(storeKey: IdProvider.storeKey, from: FileManager.privateURL){
            shared = data
        }
        else{
            shared = IdProvider()
        }
        shared.save()
    }
    
    func save(){
        FileManager.default.saveJsonFile(data: self, storeKey: IdProvider.storeKey, to: FileManager.privateURL)
    }
    
    enum CodingKeys: String, CodingKey {
        case lastId
    }
    
    var lastId: Int
    
    var nextId: Int{
        lastId += 1
        save()
        return lastId
    }
    
    init(){
        lastId = IdProvider.minNewId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lastId = try values.decodeIfPresent(Int.self, forKey: .lastId) ?? IdProvider.minNewId
        if lastId < IdProvider.minNewId{
            lastId = IdProvider.minNewId
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastId, forKey: .lastId)
    }
    
}
