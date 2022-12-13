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
    static var tileDirectory : URL!
    
    static func initializeDirectories(){
        tileDirectory = privateURL.appendingPathComponent("tiles")
        if !FileManager.default.fileExists(atPath: tileDirectory.path){
            try? FileManager.default.createDirectory(at: tileDirectory, withIntermediateDirectories: true)
            print("created tile directory")
        }
    }
    
    static var storeKey = "state"
    
    static let startCoordinate = CLLocationCoordinate2D(latitude: 53.541905, longitude: 9.683107)
    static let startZoom : Int = 4
    static let startScale : Double = World.zoomScaleFromWorld(to : startZoom)
    
    static var shared = AppState(coordinate: startCoordinate, scale: startScale)
    
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
        case showLocations
        case showCross
    }

    var scale : Double
    var coordinate : CLLocationCoordinate2D
    var showLocations : Bool = true
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
        showLocations = try values.decodeIfPresent(Bool.self, forKey: .showLocations) ?? true
        showCross = try values.decodeIfPresent(Bool.self, forKey: .showCross) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(showLocations, forKey: .showLocations)
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
