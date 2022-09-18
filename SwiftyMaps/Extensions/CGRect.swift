/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

extension CGRect{
    
    func scaleBy(_ scale: CGFloat) -> CGRect{
        CGRect(x: minX*scale, y: minY*scale, width: width*scale, height: height*scale)
    }
    
    func scaleCenteredBy(_ scale: CGFloat) -> CGRect{
        CGRect(x: midX - width*scale/2, y: midY - height*scale/2, width: width*scale, height: height*scale)
    }
    
    func expandBy(size: CGSize) -> CGRect{
        CGRect(x: minX - size.width, y: minY - size.height, width: width + 2*size.width, height: height + 2*size.height)
    }
    
}

