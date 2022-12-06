/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

extension UIButton{
    
    func setPrimaryDefaults(placeholder : String = ""){
        setTitleColor(UIColor.systemTeal, for: .disabled)
    }
    
    func setSecondaryDefaults(placeholder : String = ""){
        setTitleColor(UIColor.systemGray, for: .normal)
        setTitleColor(UIColor.systemGray3, for: .disabled)
    }
    
    @discardableResult
    func asIconButton(_ icon: String, color: UIColor = .darkGray) -> UIButton{
        setImage(UIImage(systemName: icon), for: .normal)
        self.tintColor = tintColor
        self.scaleBy(1.25)
        return self
    }
    
    @discardableResult
    func asImageButton(_ image: String) -> UIButton{
        setImage(UIImage(named: image), for: .normal)
        return self
    }
    
    func asTextButton(_ text: String, color: UIColor = .systemBlue, backgroundColor: UIColor? = nil) -> UIButton{
        setTitle(text, for: .normal)
        setTitleColor(color, for: .normal)
        tintColor = color
        if let bgcol = backgroundColor{
            self.backgroundColor = bgcol
            layer.cornerRadius = 5
            layer.masksToBounds = true
        }
        return self
    }
    
}

