/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

open class ViewController: NSViewController{
    
    public init() {
        super.init(nibName: "", bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func loadView(){
        //needed if no nib exists
        view = NSView()
    }
    
}

