/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol MapMenuDelegate{
    func updateCross()
    func zoomIn()
    func zoomOut()
}

class MapMenuView: UIView {
    
    var delegate : MapMenuDelegate? = nil
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
        
        let crossButton = UIButton().asIconButton("plus.circle")
        addSubviewWithAnchors(crossButton, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: UIEdgeInsets(top: 10, left: 5, bottom: 20, right: 5))
        crossButton.addAction(UIAction(){ action in
            AppState.shared.showCross = !AppState.shared.showCross
            self.delegate?.updateCross()
        }, for: .touchDown)
        
        let zoomInButton = UIButton().asIconButton("plus")
        addSubviewWithAnchors(zoomInButton, top: crossButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        zoomInButton.addAction(UIAction(){ action in
            self.delegate?.zoomIn()
        }, for: .touchDown)
        
        let zoomOutButton = UIButton().asIconButton("minus")
        addSubviewWithAnchors(zoomOutButton, top: zoomInButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5))
        zoomOutButton.addAction(UIAction(){ action in
            self.delegate?.zoomOut()
        }, for: .touchDown)
    }
    
}






