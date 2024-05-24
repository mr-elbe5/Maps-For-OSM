/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

extension CLLocation{
    
    var horizontalAccuracyValid : Bool{
        horizontalAccuracy >= 0 && horizontalAccuracy <= Preferences.shared.maxHorizontalUncertainty
    }
    
    var speedAccuracyValid : Bool{
        speedAccuracy >= 0 && speedUncertaintyFactor <= Preferences.shared.maxSpeedUncertaintyFactor
    }
    
}
