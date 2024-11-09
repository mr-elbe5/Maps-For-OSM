/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import UniformTypeIdentifiers

extension UTType{
    
    static var exportTypes:Array<UTType> = [UTType.jpeg, UTType.png, UTType.tiff]
    static var exportTypeNames: Array<String> = [UTType.jpeg.identifier, UTType.png.identifier, UTType.tiff.identifier]
    
    var bitmapType: NSBitmapImageRep.FileType{
        switch self{
        case .png: return .png
        case .tiff: return .tiff
        default: return .jpeg
        }
    }
    
}

