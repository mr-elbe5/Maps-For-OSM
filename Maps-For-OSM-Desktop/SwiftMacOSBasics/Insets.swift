/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

struct Insets {
    
    static var smallInset : CGFloat = 5
    
    static var defaultInset : CGFloat = 10
    
    static var zero = NSEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)

    static var smallInsets = NSEdgeInsets(top: smallInset, left: smallInset, bottom: smallInset, right: smallInset)
    
    static var defaultInsets = NSEdgeInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: defaultInset)

    static var flatInsets = NSEdgeInsets(top: 0, left: defaultInset, bottom: 0, right: defaultInset)

    static var narrowInsets = NSEdgeInsets(top: defaultInset, left: 0, bottom: defaultInset, right: 0)

    static var reverseInsets = NSEdgeInsets(top: -defaultInset, left: -defaultInset, bottom: -defaultInset, right: -defaultInset)

    static var doubleInsets = NSEdgeInsets(top: 2 * defaultInset, left: 2 * defaultInset, bottom: 2 * defaultInset, right: 2 * defaultInset)
    
}

