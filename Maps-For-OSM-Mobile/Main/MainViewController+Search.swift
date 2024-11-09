/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

extension MainViewController: SearchDelegate{
    
    func openSearch() {
        let controller = SearchViewController()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getCurrentRegion() -> CoordinateRegion {
        mapView.scrollView.visibleRegion
    }
    
    func getCurrentCenter() -> CLLocationCoordinate2D {
        mapView.scrollView.screenCenterCoordinate
    }
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, worldRect: CGRect?) {
        if let worldRect = worldRect{
            mapView.showMapRectOnMap(worldRect: worldRect)
        }
        else{
            mapView.showLocationOnMap(coordinate: coordinate)
        }
    }
    
}


