/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

public protocol SwitchDelegate{
    func switchValueDidChange(sender: LabeledSwitchView,isOn: Bool)
}

open class LabeledSwitchView : NSView{
    
    private var label = NSTextField().asLabel()
    private var switcher = NSSwitch()
    
    public var delegate : SwitchDelegate? = nil
    
    public var isOn : Bool{
        get{
            switcher.state == .on
        }
        set{
            switcher.state = newValue ? .on : .off
        }
    }
    
    open func setupView(labelText: String, isOn : Bool){
        label.stringValue = labelText
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        
        self.isOn = isOn
        switcher.target = self
        switcher.action = #selector(switchDidChange)
        addSubviewWithAnchors(switcher, top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    public func setEnabled(_ flag: Bool){
        switcher.isEnabled = flag
    }
                           
    @objc public func switchDidChange(){
        self.delegate?.switchValueDidChange(sender: self,isOn: self.isOn)
    }
    
}


