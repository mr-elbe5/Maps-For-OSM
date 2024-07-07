/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import E5IOSUI

open class NavigationButton: UIControl{
    
    public var label: UILabel
    
    public init(name: String, action: UIAction){
        label = UILabel(text: name)
        super.init(frame: .zero)
        setGrayRoundedBorders(radius: 10)
        setBackground(.systemBackground)
        addSubviewAtLeft(label)
        let linkButton = IconButton(icon: "chevron.right", tintColor: .systemBlue)
        linkButton.addAction(action, for: .touchDown)
        addSubviewWithAnchors(linkButton, trailing: trailingAnchor, insets: wideInsets).centerY(centerYAnchor)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

