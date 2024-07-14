/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5MapData

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
    
    func showSearchResult(coordinate: CLLocationCoordinate2D, mapRect: CGRect?) {
        if let mapRect = mapRect{
            mapView.showMapRectOnMap(mapRect: mapRect)
        }
        else{
            mapView.showLocationOnMap(coordinate: coordinate)
        }
    }
    
}


