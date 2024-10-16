import Foundation
import SwiftUI
import CoreLocation

@Observable class WatchPreferences: NSObject, Identifiable, Codable{
    
    public static var storeKey = "watchPreferences"
    
    static var shared = WatchPreferences()
    
    enum CodingKeys: String, CodingKey {
        case autoUpdateLocation
        case showDirection
        case showHeartRate
        case showTrackpoints
        case zoom
    }
    
    var autoUpdateLocation = true
    var showDirection = true
    var showHeartRate = true
    var showTrackpoints = true
    var zoom = LocationStatus.startZoom
    
    override init(){
        
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        autoUpdateLocation = try values.decodeIfPresent(Bool.self, forKey: .autoUpdateLocation) ?? true
        showDirection = try values.decodeIfPresent(Bool.self, forKey: .showDirection) ?? true
        showHeartRate = try values.decodeIfPresent(Bool.self, forKey: .showHeartRate) ?? true
        showTrackpoints = try values.decodeIfPresent(Bool.self, forKey: .showTrackpoints) ?? true
        zoom = try values.decodeIfPresent(Int.self, forKey: .zoom) ?? LocationStatus.startZoom
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(autoUpdateLocation, forKey: .autoUpdateLocation)
        try container.encode(showDirection, forKey: .showDirection)
        try container.encode(showHeartRate, forKey: .showHeartRate)
        try container.encode(showTrackpoints, forKey: .showTrackpoints)
        try container.encode(zoom, forKey: .zoom)
    }
    
    func save(){
        UserDefaults.standard.save(forKey: WatchPreferences.storeKey, value: self)
    }
    
}
