/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

class LabeledRadioGroup : UIView{
    
    var label = UILabel()
    var radioGroup = RadioGroup()
    
    var selectedIndex : Int{
        get{
            radioGroup.selectedIndex
        }
        set{
            radioGroup.select(newValue)
        }
    }
    
    func setupView(labelText: String){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        
        addSubview(radioGroup)
        
        label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        radioGroup.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: narrowInsets)
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledRadioGroup{
        label.textColor = color
        return self
    }
    
}

