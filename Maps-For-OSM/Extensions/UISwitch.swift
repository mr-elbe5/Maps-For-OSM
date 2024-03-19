/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

extension UISwitch{
    
    func asCheckbox() -> UISwitch{
        self.preferredStyle = .checkbox
        return self
    }
    
}

