/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIImageView{
    
    @objc func setDefaults(){
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
    }
    
    func setAspectRatioConstraint() {
        if let imageSize = image?.size, imageSize.height != 0
        {
            let aspectRatio = imageSize.width / imageSize.height
            let c = NSLayoutConstraint(item: self, attribute: .width,
                                       relatedBy: .equal,
                                       toItem: self, attribute: .height,
                                       multiplier: aspectRatio, constant: 0)
            c.priority = UILayoutPriority(900)
            self.addConstraint(c)
        }
    }
    
}


