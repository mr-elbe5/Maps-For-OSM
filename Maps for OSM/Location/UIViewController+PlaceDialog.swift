/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

extension UIViewController{
    
    func assertPlace(coordinate: CLLocationCoordinate2D, onComplete: ((Location) -> Void)? = nil){
        if let nearestPlace = Locations.placeNextTo(coordinate: coordinate, maxDistance: LocationPreferences.instance.maxLocationMergeDistance){
            var txt = nearestPlace.description
            if !txt.isEmpty{
                txt += ", "
            }
            txt += nearestPlace.coordinateString
            let alertController = UIAlertController(title: "useLocation".localize(), message: txt, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "no".localize(), style: .default) { action in
                let place = Locations.addPlace(coordinate: coordinate)
                Locations.save()
                onComplete?(place)
            })
            alertController.addAction(UIAlertAction(title: "yes".localize(), style: .cancel) { action in
                onComplete?(nearestPlace)
            })
            self.present(alertController, animated: true)
        }
        else{
            let place = Locations.addPlace(coordinate: coordinate)
            Locations.save()
            onComplete?(place)
        }
    }
    
}
