/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSButton{
    
    public convenience init(icon: String, target: NSView, action: Selector){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!, target: target, action: action)
    }
    
    public convenience init(icon: String, color: NSColor, target: NSView, action: Selector){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!.withTintColor(color), target: target, action: action)
    }
    
    public convenience init(icon: String, color: NSColor, backgroundColor: NSColor, target: NSView, action: Selector){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!.withTintColor(color), target: target, action: action)
        self.backgroundColor = backgroundColor
    }
    
    @discardableResult
    public func withStyle(_ style: BezelStyle) -> NSButton{
        self.bezelStyle = style
        return self
    }
    
    @discardableResult
    public func asIconButton(_ icon: String, color: NSColor = .darkGray) -> NSButton{
        image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)?.withTintColor(color)
        return self
    }
    
    @discardableResult
    public func asImageButton(_ image: String) -> NSButton{
        self.image = NSImage(named: image)
        return self
    }

    @discardableResult
    public func asTextButton(_ text: String, color: NSColor = .controlTextColor, backgroundColor: NSColor? = nil) -> NSButton{
        title = text
        self.contentTintColor = color
        if let bgcol = backgroundColor{
            self.wantsLayer = true
            layer?.backgroundColor = bgcol.cgColor
            layer?.cornerRadius = 5
            layer?.masksToBounds = true
        }
        return self
    }
    
    public func setAction(target: NSView, action: Selector){
        self.target = target
        self.action = action
    }
    
    @discardableResult
    public func asTextButton(_ text: String, target: NSView, action: Selector) -> NSButton{
        title = text
        self.target = target
        self.action = action
        return self
    }
    
}

