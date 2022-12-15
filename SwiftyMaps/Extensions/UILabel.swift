/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

extension UILabel{
    
    func setDefaults(text : String){
        self.text = text
    }
    
    convenience init(text: String){
        self.init()
        self.text = text
        numberOfLines = 0
        textColor = .label
    }
    
    convenience init(header: String){
        self.init()
        self.text = header
        font = .preferredFont(forTextStyle: .headline)
        numberOfLines = 0
        textColor = .label
    }
    
}

