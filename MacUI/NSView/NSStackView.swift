/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSStackView{
    
    public func removeAllArrangedSubviews(){
        for subview in arrangedSubviews{
            removeArrangedSubview(subview)
            removeSubview(subview)
        }
    }
    
    public func addText(_ text: String){
        let label = NSTextField(labelWithString: text)
        addArrangedSubview(label)
    }
    
    public func addHeader(_ text: String){
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: label.font!.pointSize)
        addArrangedSubview(label)
    }
    
    public func addButton(title: String, target: NSView, action: Selector){
        let btn = NSButton(title: title, target: target, action: action)
        btn.isBordered = false
        addArrangedSubview(btn)
    }
    
    public func addButton(title: String, icon: String, target: NSView, action: Selector){
        let btn = NSButton(title: title, image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!, target: target, action: action)
        btn.isBordered = false
        addArrangedSubview(btn)
    }
    
}

