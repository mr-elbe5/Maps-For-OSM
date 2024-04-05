/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PlaceInfoViewController: PopupScrollViewController {
    
    var stackView = UIStackView()
    
    var subInset : CGFloat = 40
    
    override func loadView() {
        title = "Info"
        super.loadView()
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        stackView.setupVertical()
        
        stackView.addArrangedSubview(InfoHeader(key: "placeInfoHeader"))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "topMenuInfoHeader"))
        stackView.addArrangedSubview(IconInfoText(icon: "pencil", key: "startEditingIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "pencil.slash", key: "endEditingIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "photo", key: "addImageInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "mic", key: "openAudioRecorderInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "pencil.and.list.clipboard", key: "addNoteInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "checkmark.square", key: "selectAllIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "square.and.arrow.up", key: "exportImagesIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "trash.square", key: "deleteSelectedIconInfoText", iconColor: .red))
        stackView.addArrangedSubview(IconInfoText(icon: "trash", key: "deletePlaceIconInfoText", iconColor: .red))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "info", key: "infoIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "xmark", key: "closeIconInfoText"))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "itemCellInfoHeader"))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "magnifyingglass", key: "itemDetailIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "map", key: "showOnMapIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "square", key: "selectIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "checkmark.square", key: "selectedIconInfoText"))
        
    }
    
}
