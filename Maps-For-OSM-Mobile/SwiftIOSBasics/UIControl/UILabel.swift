/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

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
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> UILabel{
        self.textColor = color
        return self
    }
    
}

