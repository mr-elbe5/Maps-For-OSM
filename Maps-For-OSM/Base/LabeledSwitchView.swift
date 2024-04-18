/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol SwitchDelegate{
    func switchValueDidChange(sender: LabeledSwitchView,isOn: Bool)
}

class LabeledSwitchView : UIView{
    
    private var label = UILabel()
    private var switcher = UISwitch()
    
    var delegate : SwitchDelegate? = nil
    
    var isOn : Bool{
        get{
            switcher.isOn
        }
        set{
            switcher.isOn = newValue
        }
    }
    
    func setupView(labelText: String, isOn : Bool){
        label.text = labelText
        label.textAlignment = .left
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        
        switcher.scaleBy(0.75)
        switcher.isOn = isOn
        switcher.addAction(UIAction(){ action in
            self.delegate?.switchValueDidChange(sender: self,isOn: self.switcher.isOn)
        }, for: .valueChanged)
        addSubviewWithAnchors(switcher, top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    func setEnabled(_ flag: Bool){
        switcher.isEnabled = flag
    }
    
}

