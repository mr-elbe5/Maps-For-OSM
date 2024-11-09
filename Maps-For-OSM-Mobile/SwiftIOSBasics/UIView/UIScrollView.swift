/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIScrollView{
    
    func setupVertical(){
        self.isScrollEnabled = true
        let scflg = self.contentLayoutGuide
        let svflg = self.frameLayoutGuide
        scflg.widthAnchor.constraint(equalTo: svflg.widthAnchor).isActive = true
    }
    
}

