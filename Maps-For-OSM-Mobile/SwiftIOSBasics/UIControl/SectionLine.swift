/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class SectionLine: UIControl{
    
    var label: UILabel
    
    init(name: String, action: UIAction){
        label = UILabel(text: name)
        super.init(frame: .zero)
        setGrayRoundedBorders(radius: 10)
        setBackground(.tertiarySystemBackground)
        addSubviewAtLeft(label)
        let linkButton = IconButton(icon: "chevron.right", tintColor: .systemBlue)
        linkButton.addAction(action, for: .touchDown)
        addSubviewWithAnchors(linkButton, trailing: trailingAnchor, insets: wideInsets).centerY(centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

