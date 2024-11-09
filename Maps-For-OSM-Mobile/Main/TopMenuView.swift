/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol MainMenuDelegate{
    
    func updateCross()
    func focusUserLocation()
    func openSearch()
    func refreshMap()
    
}

class TopMenuView: UIView {
    
    //MainViewController
    var delegate : MainMenuDelegate? = nil
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        
        let focusCurrentLocationButton = UIButton().asIconButton("record.circle", color: .darkText)
        addSubviewWithAnchors(focusCurrentLocationButton, top: topAnchor, bottom: bottomAnchor, insets: insets)
            .centerX(centerXAnchor)
        focusCurrentLocationButton.addAction(UIAction(){ action in
            self.delegate?.focusUserLocation()
        }, for: .touchDown)
        
        let crossButton = UIButton().asIconButton("plus.circle", color: .systemBlue)
        addSubviewWithAnchors(crossButton, top: topAnchor, trailing: focusCurrentLocationButton.leadingAnchor, insets: insets)
        crossButton.addAction(UIAction(){ action in
            AppState.shared.showCross = !AppState.shared.showCross
            self.delegate?.updateCross()
        }, for: .touchDown)
        
        let searchButton = UIButton().asIconButton("magnifyingglass", color: .darkText)
        addSubviewWithAnchors(searchButton, top: topAnchor, leading: focusCurrentLocationButton.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: insets)
        searchButton.addAction(UIAction(){ action in
            self.delegate?.openSearch()
        }, for: .touchDown)
    }
    
}






