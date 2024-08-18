/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data
import AppKit
import UniformTypeIdentifiers

open class ImageFactory {

    public static var instance : ImageFactory = ImageFactory()
    
    public func createPreview(original: NSImage, utType: UTType, maxSide: CGFloat) -> Data? {
        var source = original
        if maxSide > 0, let resized = createResizedImage(original: original, maxSide: maxSide){
            source = resized
        }
        if let tiff = source.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            if let previewData = tiffData.representation(using: utType.bitmapType, properties: [:]) {
                return previewData
            }
        }
        return nil
    }
    
    public func createResizedImage(original: NSImage, maxSide: CGFloat) -> NSImage? {
        var ratio: CGFloat
        let originalPixelSize = original.pixelSize
        if originalPixelSize.width > originalPixelSize.height{
            ratio = min(1.0,maxSide/originalPixelSize.width)
        }
        else{
            ratio = min(1.0,maxSide/originalPixelSize.height)
        }
        if ratio == 1.0{
            return original
        }
        let newWidth = floor(originalPixelSize.width * ratio)
        let newHeight = floor(originalPixelSize.height * ratio)
        let frame = NSRect(x: 0, y: 0, width: newWidth, height: newHeight)
        guard let representation = original.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: CGSize(width: newWidth, height: newHeight), flipped: false, drawingHandler: { (_) -> Bool in
            representation.draw(in: frame)
        })
        return image
    }

}

