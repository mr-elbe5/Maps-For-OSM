/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLPlacemark{
    
    var locationString: String{
        "\(thoroughfare ?? "") \(subThoroughfare ?? "")\n\(postalCode ?? "") \(locality ?? "")\n\(country ?? "")"
    }
    
    var asString: String{
        if let name = name{
            return name
        }
        return locationString
    }
    
}
