/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class CameraInfoViewController: PopupScrollViewController {
    
    var stackView = UIStackView()
    
    var subInset : CGFloat = 40
    
    override func loadView() {
        title = "info".localize(table: "Camera")
        super.loadView()
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        stackView.setupVertical()
        
        stackView.addArrangedSubview(IconInfoText(icon: "camera",text: "photoMode".localize(table: "Camera")))
        stackView.addArrangedSubview(IconInfoText(icon: "video",text: "videoMode".localize(table: "Camera")))
        stackView.addArrangedSubview(IconInfoText(icon: "square.3.layers.3d.down.right",text: "hdrMode".localize(table: "Camera")))
        stackView.addArrangedSubview(IconInfoText(icon: "square.3.layers.3d.down.right.slash",text: "noHDRMode".localize(table: "Camera")))
        stackView.addArrangedSubview(IconInfoText(icon: "bolt.badge.automatic",text: "flashModeAuto".localize(table: "Camera")))
        stackView.addArrangedSubview(IconInfoText(icon: "bolt.slash",text: "flashModeOff".localize(table: "Camera")))
        stackView.addArrangedSubview(IconInfoText(icon: "bolt",text: "flashModeOn".localize(table:"Camera")))
        stackView.addArrangedSubview(InfoText(text: "zoomIndicator".localize(table: "Camera")))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "backLensSelector".localize(table: "Camera")))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "captureButton".localize(table: "Camera")))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "cameraSelector".localize(table: "Camera")))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(text: "screenActions".localize(table: "Camera")))
        
    }
    
}
