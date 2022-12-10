//
//  AppState.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 21.09.22.
//

import Foundation
import UIKit
import AVKit
import CoreLocation

class AppState: Identifiable, Codable{
    
    static var privateURL : URL = FileManager.default.urls(for: .applicationSupportDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var filesDirectory : URL!
    static var cartoDirectory : URL!
    static var topoDirectory : URL!
    
    static func initializeDirectories(){
        filesDirectory = privateURL.appendingPathComponent("files")
        cartoDirectory = filesDirectory.appendingPathComponent("carto")
        topoDirectory = filesDirectory.appendingPathComponent("topo")
        if !FileManager.default.fileExists(atPath: cartoDirectory.path){
            try? FileManager.default.createDirectory(at: cartoDirectory, withIntermediateDirectories: true)
            print("created carto directory")
            if let files = try? FileManager.default.contentsOfDirectory(atPath: filesDirectory.path){
                var cnt = 0
                for file in files{
                    if file != "carto" && file != "topo"{
                        try? FileManager.default.moveItem(atPath: "\(filesDirectory.path)/\(file)", toPath: "\(cartoDirectory.path)/\(file)")
                        cnt += 1
                    }
                }
                if cnt > 0{
                    print("moved \(cnt) old tile directories to carto")
                }
            }
        }
        if !FileManager.default.fileExists(atPath: topoDirectory.path){
            try? FileManager.default.createDirectory(at: topoDirectory, withIntermediateDirectories: true)
            print("created topo directory")
        }
    }
    
    static var storeKey = "state"
    
    static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    static let startZoom : Int = 4
    static let startScale : Double = World.zoomScaleFromWorld(to : startZoom)
    
    static var shared = AppState(coordinate: startCoordinate, scale: startScale)
    
    static var currentUrlTemplate : String{
        switch shared.mapType{
        case .carto: return Preferences.shared.cartoUrlTemplate
        case .topo: return Preferences.shared.topoUrlTemplate
        }
    }
    
    static var currentTileDirectory : URL{
        switch shared.mapType{
        case .carto: return cartoDirectory
        case .topo: return topoDirectory
        }
    }
    
    static func loadInstance(){
        if let state : AppState = DataController.shared.load(forKey: AppState.storeKey){
            shared = state
        }
        else{
            shared = AppState(coordinate: startCoordinate, scale: startScale)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case scale
        case latitude
        case longitude
        case mapType
        case showPins
        case showCross
    }

    var scale : Double
    var coordinate : CLLocationCoordinate2D
    var mapType : MapType = .carto
    var showPins : Bool = true
    var showCross : Bool = false
    
    init(coordinate: CLLocationCoordinate2D, scale: Double){
        self.scale = scale
        self.coordinate = coordinate
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scale = try values.decode(Double.self, forKey: .scale)
        let lat = try values.decode(Double.self, forKey: .latitude)
        let lon = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        if let type = try values.decodeIfPresent(String.self, forKey: .mapType){
            mapType =  MapType(rawValue: type) ?? .carto
        }
        else{
            mapType = .carto
        }
        showPins = try values.decodeIfPresent(Bool.self, forKey: .showPins) ?? true
        showCross = try values.decodeIfPresent(Bool.self, forKey: .showCross) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(mapType.rawValue, forKey: .mapType)
        try container.encode(showPins, forKey: .showPins)
        try container.encode(showCross, forKey: .showCross)
    }
    
    func resetPosition(){
        coordinate = AppState.startCoordinate
        scale = AppState.startScale
    }
    
    func save(){
        DataController.shared.save(forKey: AppState.storeKey, value: self)
    }
    
    
}
