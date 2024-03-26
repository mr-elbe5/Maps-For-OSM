/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class SearchQuery {
    
    enum SearchRegion: String{
        case unlimited
        case current
        case country
    }
    
    enum SearchTarget: String{
        case any
        case city
        case street
        case poi
    }
    
    private var searchString: String = ""
    var target: SearchTarget = AppState.shared.searchTarget
    var region: SearchRegion = AppState.shared.searchRegion
    var maxSearchResults = Preferences.shared.maxSearchResults
    
    var coordinateRegion: CoordinateRegion? = nil
    var countryRegion: String? = nil
    
    var searchQuery: String{
        var query : String
        switch target{
        case .city:
            query = "https://nominatim.openstreetmap.org/search?city=\(searchString)&format=json&limit=\(maxSearchResults)&polygon_text=1"
        case .street:
            query =  "https://nominatim.openstreetmap.org/search?street=\(searchString)&format=json&limit=\(maxSearchResults)&polygon_text=1"
        case .poi: query =  "https://nominatim.openstreetmap.org/search?amenity=\(searchString)&format=json&limit=\(maxSearchResults)&polygon_text=1"
        default: query =  "https://nominatim.openstreetmap.org/search?q=\(searchString)&format=json&limit=\(maxSearchResults)&polygon_text=1"
        }
        if region == .current, let region = coordinateRegion{
            query += "&viewbox=\(region.minLongitude),\(region.minLatitude),\(region.maxLongitude),\(region.maxLatitude)&bounded=1"
        }
        else if region == .country, let countryCode = countryRegion{
            query += "&countrycodes=\(countryCode)"
        }
        return query
    }
    
    init(searchString: String){
        self.searchString = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    func search(completion: @escaping (_ result: Array<NominatimLocation>) -> Void)  {
        Nominatim.getLocation(query: searchQuery, completion: completion)
    }

}
