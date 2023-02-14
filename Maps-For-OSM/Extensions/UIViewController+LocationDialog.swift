/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

extension UIViewController{
    
    func assertLocation(coordinate: CLLocationCoordinate2D, onComplete: ((Location) -> Void)? = nil){
        if let nearestLocation = LocationPool.locationNextTo(coordinate: coordinate){
            var txt = nearestLocation.name
            if !txt.isEmpty{
                txt += ", "
            }
            txt += nearestLocation.coordinate.asString
            let alertController = UIAlertController(title: "useLocation".localize(), message: txt, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "no".localize(), style: .default) { action in
                let location = LocationPool.addLocation(coordinate: coordinate)
                LocationPool.save()
                onComplete?(location)
            })
            alertController.addAction(UIAlertAction(title: "yes".localize(), style: .cancel) { action in
                onComplete?(nearestLocation)
            })
            self.present(alertController, animated: true)
        }
        else{
            let location = LocationPool.addLocation(coordinate: coordinate)
            LocationPool.save()
            onComplete?(location)
        }
    }
    
}
