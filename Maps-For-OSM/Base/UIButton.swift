/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import E5IOSUI

extension UIButton{
    
    public convenience init(name: String, action: UIAction){
        self.init(frame: .zero)
        setTitle(name, for: .normal)
        setTitleColor(.systemBlue, for: .normal)
        addAction(action, for: .touchDown)
    }
    
}

