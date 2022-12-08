/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class ImageData : FileData{
    
    private var _fileName = ""
    
    override var type : FileType{
        .image
    }
    
    override var fileName : String {
        get{
            _fileName
        }
        set{
            _fileName = newValue
        }
    }
    
}
