/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

open class IconBar : NSStackView{
    
    public init(){
        super.init(frame: .zero)
        orientation = .horizontal
        spacing = smallInset
        edgeInsets = smallInsets
        backgroundColor = .tertiarySystemFill
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
