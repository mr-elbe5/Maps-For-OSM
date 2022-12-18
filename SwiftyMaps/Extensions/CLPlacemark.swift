//
//  CLPlacemark.swift
//  SwiftyMaps
//
//  Created by Michael Rönnau on 18.12.22.
//

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
