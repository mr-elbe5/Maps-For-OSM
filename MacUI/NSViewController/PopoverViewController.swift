/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

open class PopoverViewController: ViewController {
    
    public var popover = NSPopover()
    
    public var contentView: NSView? = nil
    
    override public init(){
        super.init()
        popover.contentViewController = self
        popover.behavior = .semitransient
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func loadView() {
        super.loadView()
        if let contentView = contentView{
            view.addSubviewFilling(contentView, insets: defaultInsets)
            contentView.setupView()
        }
    }
    
    open func close(){
        popover.performClose(nil)
    }
    
}

