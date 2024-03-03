/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class CameraInfoViewController: PopupScrollViewController {
    
    var stackView = UIStackView()
    
    var subInset : CGFloat = 40
    
    override func loadView() {
        title = "info".localize()
        super.loadView()
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        stackView.setupVertical()
        
        stackView.addArrangedSubview(IconInfoText(icon: "camera",text: "photoMode".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "video",text: "videoMode".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "square.3.layers.3d.down.right",text: "hdrMode".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "square.3.layers.3d.down.right.slash",text: "noHDRMode".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "bolt.badge.automatic",text: "flashModeAuto".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "bolt.slash",text: "flashModeOff".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "bolt",text: "flashModeOn".localize()))
        stackView.addArrangedSubview(InfoText(text: "zoomIndicator".localize()))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "backLensSelector".localize()))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "captureButton".localize()))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "cameraSelector".localize()))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "screenActions".localize()))
        
    }
    
}
