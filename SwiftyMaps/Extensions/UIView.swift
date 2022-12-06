/*
 My Private Track
 App for creating a diary with entry based on time and map location using text, photos, audios and videos
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

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

