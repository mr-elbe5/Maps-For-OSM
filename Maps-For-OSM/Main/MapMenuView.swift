/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData

protocol MapMenuDelegate{
    func showLocations(_ flag: Bool)
    func hideTrack()
    func refreshMap()
    func zoomIn()
    func zoomOut()
}

class MapMenuView: UIView {
    
    var showLocationsButton = UIButton().asIconButton("mappin.slash")
    
    var delegate : MapMenuDelegate? = nil
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
        
        addSubviewWithAnchors(showLocationsButton, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        showLocationsButton.addAction(UIAction(){ action in
            if AppState.shared.showLocations{
                self.delegate?.showLocations(false)
                self.showLocationsButton.setImage(UIImage(systemName: "mappin"), for: .normal)
            }
            else{
                self.delegate?.showLocations(true)
                self.showLocationsButton.setImage(UIImage(systemName: "mappin.slash"), for: .normal)
            }
        }, for: .touchDown)
        
        let hideTrackButton = UIButton().asIconButton("eraser.line.dashed")
        addSubviewWithAnchors(hideTrackButton, top: showLocationsButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        hideTrackButton.addAction(UIAction(){ action in
            self.delegate?.hideTrack()
        }, for: .touchDown)
        
        let refreshButton = UIButton().asIconButton("arrow.clockwise")
        addSubviewWithAnchors(refreshButton, top: hideTrackButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        refreshButton.addAction(UIAction(){ action in
            self.delegate?.refreshMap()
        }, for: .touchDown)
        
        let zoomInButton = UIButton().asIconButton("plus")
        addSubviewWithAnchors(zoomInButton, top: refreshButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
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






