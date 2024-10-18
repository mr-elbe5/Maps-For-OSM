import Foundation
import SwiftUI
import CoreLocation
import E5Data

@Observable class WatchPreferences: NSObject, Identifiable, Codable{
    
    public static var storeKey = "watchPreferences"
    
    static var shared = WatchPreferences()
    
    static func loadShared(){
        if let prefs : WatchPreferences = UserDefaults.standard.load(forKey: storeKey){
            shared = prefs
            Log.info("loaded watch preferences")
        }
        else{
            Log.info("no saved data available for watch preferences")
            shared = WatchPreferences()
            shared.save()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case autoUpdateLocation
        case showDirection
        case zoom
    }
    
    var autoUpdateLocation = true
    var showDirection = true
    var zoom = LocationStatus.startZoom
    
    override init(){
        
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        autoUpdateLocation = try values.decodeIfPresent(Bool.self, forKey: .autoUpdateLocation) ?? true
        showDirection = try values.decodeIfPresent(Bool.self, forKey: .showDirection) ?? true
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? LocationStatus.startZoom
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(autoUpdateLocation, forKey: .autoUpdateLocation)
        try container.encode(showDirection, forKey: .showDirection)
        try container.encode(zoom, forKey: .zoom)
    }
    
    func save(){
        UserDefaults.standard.save(forKey: WatchPreferences.storeKey, value: self)
    }
    
}
