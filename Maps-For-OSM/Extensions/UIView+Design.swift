/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIView{
    
    var transparentColor : UIColor{
        if isDarkMode{
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        }
        else{
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        }
    }
    
    var iconColor : UIColor{
        UIColor(red: 0.0, green: 0.5, blue: 0.7, alpha: 1.0)
    }
    
    var lightIconColor : UIColor{
        UIColor(red: 0.0, green: 0.7, blue: 0.9, alpha: 1.0)
    }
    
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
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = radius
        layer.masksToBounds = true
        return self
    }
    
}

