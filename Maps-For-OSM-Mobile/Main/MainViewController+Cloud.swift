/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension MainViewController: ICloudDelegate{
    
    func dataChanged() {
        mapView.updateLocationLayer()
    }
    
}

