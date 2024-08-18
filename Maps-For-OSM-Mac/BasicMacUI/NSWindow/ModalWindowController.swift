/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import AppKit

open class ModalWindowController: NSWindowController, NSWindowDelegate{
    
    public convenience init(title: String, viewController: NSViewController, outerWindow: NSWindow, minSize: CGSize){
        let window = ModalWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false)
        window.minSize = minSize
        window.title = title
        window.level = .modalPanel
        window.outerWindow = outerWindow
        self.init(window: window)
        window.delegate = self
        contentViewController = viewController
    }
    
    public func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }
    
}
