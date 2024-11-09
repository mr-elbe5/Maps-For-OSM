/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

class IconBar : NSStackView{
    
    init(){
        super.init(frame: .zero)
        orientation = .horizontal
        spacing = smallInset
        edgeInsets = smallInsets
        backgroundColor = .tertiarySystemFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
