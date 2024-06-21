/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI

class TileSourceInfoViewController: PopupScrollViewController {
    
    var stackView = UIStackView()
    
    var subInset : CGFloat = 40
    
    override func loadView() {
        title = "Info"
        super.loadView()
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        stackView.setupVertical()
        
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "tileSourceInfoHeader"))
        stackView.addArrangedSubview(InfoText(key: "tileSourceInfoText"))
        stackView.addArrangedSubview(InfoText(key: "urlInfoText"))
        
    }
    
}