/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIImageView{
    
    @discardableResult
    func withDefaults() -> UIImageView{
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
        return self
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


