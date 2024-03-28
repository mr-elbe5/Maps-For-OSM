/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class MainInfoViewController: PopupScrollViewController {
    
    var stackView = UIStackView()
    
    var subInset : CGFloat = 40
    
    override func loadView() {
        title = "Info"
        super.loadView()
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        stackView.setupVertical()
        
        stackView.addArrangedSubview(UILabel(header: "appInfoHeader".localize()))
        stackView.addArrangedSubview(UILabel(text: "appInfoText".localize()))
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "mapIconsInfoHeader".localize()))
        
        // user location
        stackView.addArrangedSubview(IconInfoText(icon: "record.circle", text: "currentLocationInfoText".localize(), iconColor: CurrentLocationView.currentLocationColor))
        // cross
        stackView.addArrangedSubview(IconInfoText(icon: "plus.circle", text: "crossLocationInfoText".localize(), iconColor: .systemBlue))
        // location
        stackView.addArrangedSubview(IconInfoText(image: "mappin.green", text: "placeMarkerInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.red", text: "placeMediaMarkerInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.blue", text: "placeTrackMarkerInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.purple", text: "placeMediaTrackMarkerInfoText".localize()))
        stackView.addArrangedSubview(InfoText(text: "placeDetailsInfoText".localize(), leftInset: subInset))
        //location group
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.green", text: "placeGroupInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.red", text: "placeMediaGroupInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.blue", text: "placeTrackGroupInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.purple", text: "placeMediaTrackGroupInfoText".localize()))
        stackView.addArrangedSubview(InfoText(text: "placeGroupInfoText".localize(), leftInset: subInset))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "mainMenuInfoHeader".localize()))
        
        // main menu
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "mappin", text: "placeMenuInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "list.bullet", text: "placeListInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "mappin", text: "showPlacesInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "mappin.slash", text: "hidePlacesInfoText".localize(), leftInset: subInset))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk", text: "trackMenuInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "list.bullet", text: "trackListInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "square.and.arrow.down", text: "importTrackInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "eye.slash", text: "hideTrackInfoText".localize(), leftInset: subInset))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "record.circle", text: "centerIconInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "magnifyingglass", text: "searchIconInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "gearshape", text: "gearIconInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "info.circle", text: "infoIconInfoText".localize()))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "actionMenuInfoHeader".localize()))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk.departure", text: "startTrackInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk.motion", text: "stopTrackInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "camera", text: "openCameraInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "mic", text: "openAudioRecorderInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "pencil.and.list.clipboard", text: "addNoteInfoText".localize()))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "mapMenuInfoHeader".localize()))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "plus.circle", text: "crossIconInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "plus", text: "zoomInInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "minus", text: "zoomOutInfoText".localize()))
        
        
    }
    
}
