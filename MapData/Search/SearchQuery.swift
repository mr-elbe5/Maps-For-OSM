/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import E5Data

open class SearchQuery {
    
    public enum SearchRegion: Int{
        case unlimited
        case current
        case radius
    }
    
    public enum SearchTarget: Int{
        case any
        case city
        case street
        case poi
    }
    
    public var coordinateRegion: CoordinateRegion? = nil
    public var searchRadius: Double = AppState.shared.searchRadius
    
    public var searchQuery: String?{
        if let searchString = AppState.shared.searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
            var query : String
            switch AppState.shared.searchTarget{
            case .city:
                query = "https://nominatim.openstreetmap.org/search?city=\(searchString)&format=json&limit=\(Preferences.shared.maxSearchResults)&polygon_text=1"
            case .street:
                query =  "https://nominatim.openstreetmap.org/search?street=\(searchString)&format=json&limit=\(Preferences.shared.maxSearchResults)&polygon_text=1"
            case .poi: query =  "https://nominatim.openstreetmap.org/search?amenity=\(searchString)&format=json&limit=\(Preferences.shared.maxSearchResults)&polygon_text=1"
            default: query =  "https://nominatim.openstreetmap.org/search?q=\(searchString)&format=json&limit=\(Preferences.shared.maxSearchResults)&polygon_text=1"
            }
            if AppState.shared.searchRegion == .current || AppState.shared.searchRegion == .radius, let region = coordinateRegion{
                query += "&viewbox=\(region.minLongitude),\(region.minLatitude),\(region.maxLongitude),\(region.maxLatitude)&bounded=1"
            }
            return query
        }
        return nil
    }
    
    public init(){
    }
    
    public func search(completion: @escaping (_ result: Array<NominatimLocation>?) -> Void)  {
        if let query = searchQuery{
            Nominatim.getLocation(query: query, completion: completion)
        }
        else{
            completion(nil)
        }
    }

}
