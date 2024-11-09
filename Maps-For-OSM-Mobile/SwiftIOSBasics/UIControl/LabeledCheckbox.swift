/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class LabeledCheckbox : Checkbox{
    
    func setup(title: String, index: Int = 0, isOn: Bool = false){
        self.index = index
        self.title = title
        self.isOn = isOn
        label.font = .preferredFont(forTextStyle: .headline)
        checkboxIcon.delegate = self
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, insets: narrowInsets)
        let vw = UIView()
        vw.setRoundedBorders()
        addSubviewWithAnchors(vw, top: label.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: narrowInsets)
        vw.addSubviewFilling(checkboxIcon, insets: smallInsets)
    }
    
    func setupInline(title: String, index: Int = 0, isOn: Bool = false){
        self.index = index
        self.title = title
        self.isOn = isOn
        label.font = .preferredFont(forTextStyle: .headline)
        checkboxIcon.delegate = self
        let vw = UIView()
        vw.setRoundedBorders()
        addSubviewWithAnchors(vw, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: narrowInsets)
        vw.addSubviewFilling(checkboxIcon, insets: smallInsets)
        addSubviewWithAnchors(label, top: topAnchor, leading: vw.trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
    @discardableResult
    override func withTextColor(_ color: UIColor) -> LabeledCheckbox{
        label.textColor = color
        super.withTextColor(color)
        return self
    }
    
}
