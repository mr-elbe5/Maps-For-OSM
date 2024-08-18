/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

open class FormViewController: NSViewController {
    
    public var formGrid = NSGridView()
    public var okButton = NSButton().withStyle(.roundRect)
    public var cancelButton = NSButton().withStyle(.roundRect)
    
    override open func loadView() {
        super.loadView()
        view.addSubview(formGrid)
        formGrid.setAnchors(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, insets: defaultInsets)
        fillGrid()
        cancelButton.title = "cancel".localize()
        cancelButton.target = self
        cancelButton.action = #selector(onCancel)
        view.addSubview(cancelButton)
        cancelButton.setAnchors(leading: view.leadingAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
        okButton.title = "ok".localize()
        okButton.target = self
        okButton.action = #selector(onOk)
        view.addSubview(okButton)
        okButton.setAnchors(trailing: view.trailingAnchor, bottom: view.bottomAnchor, insets: defaultInsets)
    }
    
    open func fillGrid(){
        
    }
    
    @objc open func onCancel(){
        NSApp.stopModal(withCode: .cancel)
        view.window?.close()
    }
    
    @objc open func onOk(){
        NSApp.stopModal(withCode: .OK)
        view.window?.close()
    }
    
}

