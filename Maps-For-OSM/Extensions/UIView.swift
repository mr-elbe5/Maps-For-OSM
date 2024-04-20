/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIView{
    
    func getExtendedIntrinsicContentSize(originalSize: CGSize) -> CGSize{
        let height = originalSize.height + 6
        layer.cornerRadius = height/2
        layer.masksToBounds = true
        return CGSize(width: originalSize.width + 16, height: height)
    }
    
    func scaleBy(_ factor: CGFloat){
        self.transform = CGAffineTransform(scaleX: factor, y:factor)
    }
    
    var firstResponder : UIView? {
        guard !isFirstResponder else {
            return self
        }
        for subview in subviews {
            if let view = subview.firstResponder {
                return view
            }
        }
        return nil
    }

}

