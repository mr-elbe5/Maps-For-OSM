/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

open class StackViewController: NSViewController {
    
    public var stackView = NSStackView()
    public var okButton = NSButton().withStyle(.roundRect)
    public var cancelButton = NSButton().withStyle(.roundRect)
    
    override open func loadView() {
        super.loadView()
        stackView.orientation = .vertical
        view.addSubviewFilling(stackView, insets: defaultInsets)
    }
    
    public func addText(_ text: String){
        let label = NSTextField(labelWithString: text)
        stackView.addArrangedSubview(label)
    }
    
    public func addHeader(_ text: String){
        let label = NSTextField(labelWithString: text)
        label.font = .boldSystemFont(ofSize: label.font!.pointSize)
        stackView.addArrangedSubview(label)
    }
    
}

