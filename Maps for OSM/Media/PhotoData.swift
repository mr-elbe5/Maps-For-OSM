/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PhotoData : ImageData{
    
    override var type : FileType{
        .photo
    }
    
    override var fileName : String {
        get{
            "img_\(id)_\(creationDate.shortFileDate()).jpg"
        }
        set{
        }
    }
    
}

