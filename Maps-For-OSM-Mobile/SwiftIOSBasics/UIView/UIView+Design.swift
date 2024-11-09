/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIView{
    
    var isDarkMode: Bool {
        self.traitCollection.userInterfaceStyle == .dark
    }
    
    @discardableResult
    func setBackground(_ color:UIColor) -> UIView{
        backgroundColor = color
        return self
    }
    
    @discardableResult
    func setRoundedEdges(radius: CGFloat = 5) -> UIView{
        layer.borderWidth = 0
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func setRoundedBorders(radius: CGFloat = 5) -> UIView{
        layer.borderWidth = 0.5
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func setGrayRoundedBorders(radius: CGFloat = 5) -> UIView{
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }
    
}

