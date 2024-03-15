/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PlaceGroupViewController: PopupScrollViewController{
    
    let noteContainerView = UIView()
    let placeStackView = UIStackView()
    
    var group: PlaceGroup
    
    init(group: PlaceGroup){
        self.group = group
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "placeGroup".localize()
        super.loadView()
        scrollView.setupVertical()
        setupContent()
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        let mergeButton = UIButton().asIconButton("arrow.triangle.merge", color: .label)
        headerView.addSubviewWithAnchors(mergeButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        mergeButton.addAction(UIAction(){ action in
            self.mergePlaces()
        }, for: .touchDown)
        
    }
    
    func setupContent(){
        var header = UILabel(header: "center".localize())
        contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: group.centralCoordinate?.asString ?? "")
        contentView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        header = UILabel(header: "places".localize())
        contentView.addSubviewWithAnchors(header, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        placeStackView.axis = .vertical
        placeStackView.spacing = .zero
        contentView.addSubviewWithAnchors(placeStackView, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: flatInsets)
        for place in group.places{
            let placeView = UIView()
            placeStackView.addArrangedSubview(placeView)
            let locationLabel = UILabel(header: place.address)
            placeView.addSubviewWithAnchors(locationLabel, top: placeView.topAnchor, leading: placeView.leadingAnchor, trailing: placeView.trailingAnchor, insets: flatInsets)
            let coordinateLabel = UILabel(text: place.coordinate.asString)
            placeView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: placeView.leadingAnchor, trailing: placeView.trailingAnchor, bottom: placeView.bottomAnchor, insets: flatInsets)
        }
        
    }
    
    func mergePlaces(){
        
    }
    
}

