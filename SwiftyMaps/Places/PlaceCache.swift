/*
 OSM-Maps
 Project for displaying a map like OSM without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import UIKit

class PlaceCache: Codable{
    
    static var storeKey = "places"
    
    static var instance : PlaceCache!
    
    static func loadInstance(){
        if let cache : PlaceCache = DataController.shared.load(forKey: .places){
            instance = cache
        }
        else{
            instance = PlaceCache()
        }
    }
    
    enum CodingKeys: String, CodingKey{
        case places
    }
    
    var places : [PlaceData]
    
    private var lock = DispatchSemaphore(value: 1)
    
    init(){
        places = [PlaceData]()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        places = try values.decodeIfPresent([PlaceData].self, forKey: .places) ?? [PlaceData]()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(places, forKey: .places)
    }
    
    @discardableResult
    func addPlace(location: CLLocation) -> PlaceData{
        lock.wait()
        defer{lock.signal()}
        let place = PlaceData(location: location)
        places.append(place)
        return place
    }
    
    func removePlace(_ place: PlaceData){
        lock.wait()
        defer{lock.signal()}
        for idx in 0..<places.count{
            if places[idx].id == place.id{
                places.remove(at: idx)
                return
            }
        }
    }
    
    func placesInPlanetRect(_ rect: CGRect) -> [PlaceData]{
        var result = [PlaceData]()
        for place in places{
            if place.planetPosition.x >= rect.minX && place.planetPosition.x < rect.minX + rect.width && place.planetPosition.y >= rect.minY && place.planetPosition.y < rect.minY + rect.height{
                result.append(place)
                //print("found place at \(place.planetPosition) in \(rect)")
            }
        }
        return result
    }
    
    func save(){
        DataController.shared.save(forKey: .places, value: self)
    }
    
}
