/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

class LabeledCheckboxGroup : UIView{
    
    var label = UILabel()
    var checkboxGroup = CheckboxGroupView()
    
    var selectedIndex : Int{
        get{
            checkboxGroup.selectedIndex
        }
        set{
            checkboxGroup.select(newValue)
        }
    }
    
    func setupView(labelText: String){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        
        addSubview(checkboxGroup)
        checkboxGroup.setup()
        
        label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        checkboxGroup.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: narrowInsets)
    }
    
    func addCheckbox(cb: Checkbox){
        checkboxGroup.addCheckbox(cb: cb)
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledCheckboxGroup{
        label.textColor = color
        return self
    }
    
}

