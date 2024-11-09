/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UISwitch{
    
    func asCheckbox() -> UISwitch{
        self.preferredStyle = .checkbox
        return self
    }
    
}

