/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIColor{
    
    static var transparentColor = UIColor(white: 1.0, alpha: 0.5)
    
    static var iconViewColor = UIColor(white: 1.0, alpha: 0.5)
    
    static func setColors(){
        background = .black
        tableBackground = .black
        sectionHeaderBackground = UIColor.tertiarySystemBackground
        subheaderBackground = UIColor.tertiarySystemBackground
        cellBackground = UIColor.secondarySystemBackground
        scrollViewBackground = UIColor.systemBackground
        sectionBackground = UIColor.systemBackground
        navbarBackground = .black
        
        text = .label
        icon = .darkText
        iconDisabled = .systemGray
        button = UIColor.systemBlue
        buttonDisabled = UIColor.systemGray
        navbarTint = .white
        sectionHeaderText = .label
        
        borderColor = UIColor.lightGray
        
        UIBarStyle.current = UIBarStyle.black
    }
    
}

