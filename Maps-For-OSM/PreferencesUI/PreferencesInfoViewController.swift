/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PreferencesInfoViewController: PopupScrollViewController {
    
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
        stackView.addArrangedSubview(UILabel(header: "appIconsHeader".localize()))
        
        // user location
        stackView.addArrangedSubview(IconInfoText(icon: "record.circle", text: "currentLocationInfoText".localize(), iconColor: CurrentLocationView.currentLocationColor))
        // cross
        stackView.addArrangedSubview(IconInfoText(icon: "plus.circle", text: "crossLocationInfoText".localize(), iconColor: .systemBlue))
        // location
        stackView.addArrangedSubview(IconInfoText(image: "mappin.green", text: "placeMarkerInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.red", text: "placePhotoMarkerInfoText".localize()))
        stackView.addArrangedSubview(InfoText(text: "placeDetailsInfoText".localize(), leftInset: subInset))
        //location group
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.green", text: "placeDefaultGroupInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(image: "mappin.group.red", text: "placePhotoGroupInfoText".localize()))
        stackView.addArrangedSubview(InfoText(text: "placeGroupInfoText".localize(), leftInset: subInset))
        
        // top menu
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "topMenuInfoHeader".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "map", text: "mapMenuInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "arrow.clockwise", text: "reloadIconInfoText".localize(),leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "square.and.arrow.down", text: "preloadIconInfoText".localize(),leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "trash", text: "deleteTilesInfoText".localize(), iconColor: .red, leftInset: subInset))
        
        // location menu
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "mappin", text: "placeMenuInfoText".localize()))
        stackView.addArrangedSubview(InfoText(text: "addPlaceInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "list.bullet", text: "placeListInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "mappin", text: "showPlacesInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "mappin.slash", text: "hidePlacesInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "trash", text: "deletePlacesInfoText".localize(), iconColor: .red, leftInset: subInset))
        
        // track menu
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk", text: "trackMenuInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk", text: "startTrackInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(InfoText(text: "startTrackLocationInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "figure.walk", text: "currentTrackInfoText".localize(), iconColor: .green, leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "eye.slash", text: "hideTrackInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "list.bullet", text: "trackListInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "trash", text: "deleteTracksInfoText".localize(), iconColor: .red, leftInset: subInset))
        //cross
        stackView.addArrangedSubview(IconInfoText(icon: "plus.circle", text: "crossIconInfoText".localize()))
        // center
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "record.circle", text: "centerIconInfoText".localize()))
        // camera
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "camera", text: "cameraIconInfoText".localize()))
        stackView.addArrangedSubview(InfoText(text: "addMediaPlaceInfoText".localize(), leftInset: subInset))
        //search
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "magnifyingglass", text: "searchIconInfoText".localize()))
        // preferences
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "gearshape", text: "gearIconInfoText".localize()))
        // info
        stackView.addSpacer()
        stackView.addArrangedSubview(IconInfoText(icon: "info.circle", text: "infoIconInfoText".localize()))
        
        // info for location detail
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "placeDetailInfoHeader".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "photo", text: "placeDetailImageInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "trash", text: "placeDetailTrashInfoText".localize(), iconColor: .red))
        stackView.addArrangedSubview(IconInfoText(icon: "pencil.circle", text: "placeDetailPencilInfoText".localize()))
        stackView.addArrangedSubview(InfoText(text: "placeDetailEditInfoText".localize(), leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "square.and.arrow.up", text: "placeDetailShareImageInfo".localize(), iconColor: .blue, leftInset: subInset))
        stackView.addArrangedSubview(IconInfoText(icon: "magnifyingglass", text: "placeDetailViewImageInfo".localize(), iconColor: .blue, leftInset: subInset))
        
        // info for track detail
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "trackDetailInfoHeader".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "map", text: "trackDetailMapInfoText".localize()))
        // info for preload
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "tilePreloadInfoHeader".localize()))
        stackView.addArrangedSubview(InfoText(text: "preloadInfoText".localize(), leftInset: subInset))
        // info for place list
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "placeListInfoHeader".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "map", text: "placeListMapInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "magnifyingglass", text: "placeListViewInfoText".localize()))
        // info for track list
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "trackListInfoHeader".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "map", text: "trackListPinInfoText".localize()))
        stackView.addArrangedSubview(IconInfoText(icon: "magnifyingglass", text: "trackListViewInfoText".localize()))
        // info for preferences
        stackView.addSpacer()
        stackView.addArrangedSubview(UILabel(header: "preferencesInfoHeader".localize()))
        stackView.addArrangedSubview(InfoText(text: "urlInfoText".localize(), leftInset: subInset))
    }
    
}
