/*
 E5MapData
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLPlacemark{
    
    public static func getPlacemark(for location: CLLocation, result: @escaping(CLPlacemark?) -> Void){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if let error = error{
                print(error)
                result(nil)
                return
            }
            if let placemark =  placemarks?[0]{
                print("got placemark")
                result(placemark)
            }
            else{
                print("no placemark")
                result(nil)
            }
        })
    }
    
    public var nameString: String?{
        if let name = name{
            if name.isEmpty || name == postalCode{
                return nil
            }
            else{
                return name
            }
        }
        return nil
    }
    
    public var locationString: String{
        let streetAddress = "\(thoroughfare ?? "") \(subThoroughfare ?? "")".trim()
        return streetAddress.isEmpty ?
        "\(postalCode ?? "") \(locality ?? "")\n\(country ?? "")" :
        "\(streetAddress)\n\(postalCode ?? "") \(locality ?? "")\n\(country ?? "")"
    }
    
    public var asString: String{
        if let name = name, !name.isEmpty{
            return name
        }
        return locationString
    }
    
}
