import Foundation
import SwiftUI
import CoreLocation

@Observable class Preferences: NSObject, Identifiable, Codable{
    
    static var storeKey = "watchPreferences"
    
    static var startZoom: Int = 16
    
    static var shared = Preferences()
    
    static func loadShared(){
        if let prefs : Preferences = UserDefaults.standard.load(forKey: storeKey){
            shared = prefs
            Log.info("loaded watch preferences")
        }
        else{
            Log.info("no saved data available for watch preferences")
            shared = Preferences()
            shared.save()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case autoUpdateLocation
        case showDirection
        case zoom
    }
    
    var trackpointInterval: Double = 5.0
    var minHorizontalTrackpointDistance: Double = 5.0
    
    var autoUpdateLocation = true
    var showDirection = true
    var zoom = Preferences.startZoom
    
    override init(){
        
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        autoUpdateLocation = try values.decodeIfPresent(Bool.self, forKey: .autoUpdateLocation) ?? true
        showDirection = try values.decodeIfPresent(Bool.self, forKey: .showDirection) ?? true
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? Preferences.startZoom
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(autoUpdateLocation, forKey: .autoUpdateLocation)
        try container.encode(showDirection, forKey: .showDirection)
        try container.encode(zoom, forKey: .zoom)
    }
    
    func save(){
        UserDefaults.standard.save(forKey: Preferences.storeKey, value: self)
    }
    
}
