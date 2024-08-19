/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import AppKit

open class ModalViewController: ViewController, ModalResponder{
    
    public var responseCode: NSApplication.ModalResponse = .cancel
    
}


