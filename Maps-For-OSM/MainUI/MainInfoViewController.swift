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
        
        stackView.addArrangedSubview(InfoHeader(key: "appInfoHeader"))
        stackView.addArrangedSubview(InfoText(key: "appInfoText"))
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "mapIconsInfoHeader"))
        
        // user location
        stackView.addArrangedSubview(IconInfoText(icon: "record.circle", key: "currentLocationInfoText", iconColor: CurrentLocationView.currentLocationColor))
        // cross
        stackView.addArrangedSubview(IconInfoText(icon: "plus.circle", key: "crossLocationInfoText", iconColor: .systemBlue))
        // location
        stackView.addArrangedSubview(IconInfoText(image: "mappin.green", key: "placeMarkerInfoText"))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.red", key: "placeMediaMarkerInfoText"))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.blue", key: "placeTrackMarkerInfoText"))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.purple", key: "placeMediaTrackMarkerInfoText"))
        stackView.addArrangedSubview(InfoText(key: "placeDetailsInfoText", leftInset: subInset))
        //location group
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.green", key: "placeGroupInfoText"))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.red", key: "placeMediaGroupInfoText"))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.blue", key: "placeTrackGroupInfoText"))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.purple", key: "placeMediaTrackGroupInfoText"))
        stackView.addArrangedSubview(InfoText(key: "placeGroupInfoText", leftInset: subInset))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "mainMenuInfoHeader"))
        
        // main menu
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "mappin", key: "placeMenuInfoText", iconColor: .systemGreen))
        stackView.addArrangedSubview(IconInfoText(icon: "list.bullet", key: "placeListInfoText", leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "mappin", key: "showPlacesInfoText", leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "mappin.slash", key: "hidePlacesInfoText", leftInset: subInset))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk", key: "trackMenuInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "list.bullet", key: "trackListInfoText", leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "square.and.arrow.down", key: "importTrackInfoText", leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "eye.slash", key: "hideTrackInfoText", leftInset: subInset))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "photo", key: "imageMenuInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "list.bullet", key: "imageListInfoText", leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "square.and.arrow.down", key: "importImagesInfoText", leftInset: subInset))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "record.circle", key: "centerIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "magnifyingglass", key: "searchIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "gearshape", key: "gearIconInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "info", key: "infoIconInfoText"))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "actionMenuInfoHeader"))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk.departure", key: "startTrackInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk.motion", key: "stopTrackInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "camera", key: "openCameraInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "mic", key: "openAudioRecorderInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "pencil.and.list.clipboard", key: "addNoteInfoText"))
        
        stackView.addSpacer()
        stackView.addArrangedSubview(InfoHeader(key: "mapMenuInfoHeader"))
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "plus.circle", key: "crossIconInfoText", iconColor: .systemBlue))
        stackView.addArrangedSubview(IconInfoText(icon: "plus", key: "zoomInInfoText"))
        stackView.addArrangedSubview(IconInfoText(icon: "minus", key: "zoomOutInfoText"))
        
        
    }
    
}
