/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class LabeledText : UIView{
    
    private var label = UILabel()
    private var textField = UILabel()
    
    var text: String{
        get{
            return textField.text ?? ""
        }
        set{
            textField.text = newValue
        }
    }
    
    func setupView(labelText: String, text: String = "", isHorizontal : Bool = true){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        textField.text = text
        addSubview(textField)
        if isHorizontal{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: centerXAnchor, bottom: bottomAnchor, insets: defaultInsets)
            textField.setAnchors(top: topAnchor, leading: centerXAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        }
        else{
            label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: defaultInsets)
            textField.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        }
    }
    
}

