/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data

extension MainViewController{
    
    func openPreloadTiles() {
        let region = mapView.scrollView.tileRegion
        let controller = TilePreloadViewController()
        controller.mapRegion = region
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func deleteAllTiles(){
        TileProvider.shared.deleteAllTiles()
        mapView.clearTiles()
    }
    
}
