/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSImageView{
    
    public convenience init(icon: String){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!)
    }
    
    public convenience init(icon: String, color: NSColor){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!.withTintColor(color))
    }
    
    public func setAspectRatioConstraint() {
        if let imageSize = image?.size, imageSize.height != 0
        {
            let aspectRatio = imageSize.width / imageSize.height
            let c = NSLayoutConstraint(item: self, attribute: .width,
                                       relatedBy: .equal,
                                       toItem: self, attribute: .height,
                                       multiplier: aspectRatio, constant: 0)
            c.priority = NSLayoutConstraint.Priority(900)
            self.addConstraint(c)
        }
    }
    
}

