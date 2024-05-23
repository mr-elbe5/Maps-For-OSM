/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CommonBasics
import IOSBasics

class PreloadInfoViewController: PopupScrollViewController {
    
    var stackView = UIStackView()
    
    var subInset : CGFloat = 40
    
    override func loadView() {
        title = "Info"
        super.loadView()
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        stackView.setupVertical()
        
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "tilePreloadInfoHeader"))
        stackView.addArrangedSubview(InfoText(key: "tilePreloadInfoText", leftInset: subInset))
        
    }
    
}
