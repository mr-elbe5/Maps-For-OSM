/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

extension NSAttributedString{
    
    func height(width: CGFloat) -> CGFloat{
        let sz = boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading] , context: nil)
        return sz.height
    }
    
    func size(width: CGFloat) -> CGSize{
        return CGSize(width: width, height: height(width: width))
    }
    
}
