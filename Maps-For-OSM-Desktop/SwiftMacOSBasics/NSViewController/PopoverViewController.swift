/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

class PopoverViewController: ViewController {
    
    var popover = NSPopover()
    
    var contentView: NSView? = nil
    
    override init(){
        super.init()
        popover.contentViewController = self
        popover.behavior = .semitransient
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        if let contentView = contentView{
            view.addSubviewFilling(contentView, insets: defaultInsets)
            contentView.setupView()
        }
    }
    
    func close(){
        popover.performClose(nil)
    }
    
}

