/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import AppKit

extension NSViewController{
    
    public var defaultInset : CGFloat{
        Insets.defaultInset
    }
    
    public var defaultInsets : NSEdgeInsets{
        Insets.defaultInsets
    }
    
    public var smallInset : CGFloat{
        Insets.smallInset
    }
    
    public var smallInsets : NSEdgeInsets{
        Insets.smallInsets
    }
    
    public var doubleInsets : NSEdgeInsets{
        Insets.doubleInsets
    }
    
    public var flatInsets : NSEdgeInsets{
        Insets.flatInsets
    }
    
    public var narrowInsets : NSEdgeInsets{
        Insets.narrowInsets
    }
    
    public func showSuccess(title: String, text: String){
        NSAlert.showSuccess(title: title, message: text)
    }
    
    public func showError(text: String){
        NSAlert.showError(message: text)
    }
    
    public func showDestructiveApprove(title: String, text: String, onApprove: (() -> Void)? = nil){
        if NSAlert.acceptWarning(title: title, message: text){
            onApprove?()
        }
    }
    
    public func showApprove(title: String, text: String, onApprove: (() -> Void)? = nil){
        if NSAlert.acceptInfo(title: title, message: text){
            onApprove?()
        }
    }
    
    public func showInfo(text: String){
        NSAlert.showMessage(message: text)
    }
    
    public func startSpinner() -> NSProgressIndicator{
        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.controlSize = .regular
        view.addSubview(spinner)
        spinner.setAnchors(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        spinner.startAnimation(nil)
        return spinner
    }
    
    public func stopSpinner(_ spinner: NSProgressIndicator?) {
        if let spinner = spinner{
            spinner.stopAnimation(nil)
            self.view.removeSubview(spinner)
        }
    }
    
}

