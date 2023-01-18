/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class InfoText : UIView{
    
    let text = UILabel()
    
    init(text: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        self.text.text = text
        self.text.numberOfLines = 0
        self.text.textColor = .label
        addSubviewWithAnchors(self.text, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: leftInset, bottom: defaultInset, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

