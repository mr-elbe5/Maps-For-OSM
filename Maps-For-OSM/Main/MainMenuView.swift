/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

protocol MainMenuDelegate{
    
    func showLocations(_ show: Bool)
    func hideTrack()
    func focusUserLocation()
    func openSearch()
    func refreshMap()
    
}

class MainMenuView: UIView {
    
    var viewMenuButton = UIButton().asIconButton("map")
    
    //MainViewController
    var delegate : MainMenuDelegate? = nil
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        
        let focusCurrentLocationButton = UIButton().asIconButton("record.circle")
        addSubviewWithAnchors(focusCurrentLocationButton, top: topAnchor, bottom: bottomAnchor, insets: insets)
            .centerX(centerXAnchor)
        focusCurrentLocationButton.addAction(UIAction(){ action in
            self.delegate?.focusUserLocation()
        }, for: .touchDown)
        
        addSubviewWithAnchors(viewMenuButton, top: topAnchor, leading: leadingAnchor, trailing: focusCurrentLocationButton.leadingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 20))
        viewMenuButton.menu = getViewMenu()
        viewMenuButton.showsMenuAsPrimaryAction = true
        
        let searchButton = UIButton().asIconButton("magnifyingglass")
        addSubviewWithAnchors(searchButton, top: topAnchor, leading: focusCurrentLocationButton.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: insets)
        searchButton.addAction(UIAction(){ action in
            self.delegate?.openSearch()
        }, for: .touchDown)
    }
    
    func getViewMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if AppState.shared.showLocations{
            actions.append(UIAction(title: "hideLocations".localize(), image: UIImage(systemName: "mappin.slash")){ action in
                self.delegate?.showLocations(false)
                self.updateLocationMenu()
            })
        }
        else{
            actions.append(UIAction(title: "showLocations".localize(), image: UIImage(systemName: "mappin")){ action in
                self.delegate?.showLocations(true)
                self.updateLocationMenu()
                
            })
        }
        actions.append(UIAction(title: "hideTrack".localize(), image: UIImage(systemName: "eraser.line.dashed")){ action in
            self.delegate?.hideTrack()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func updateLocationMenu(){
        self.viewMenuButton.menu = self.getViewMenu()
    }
    
}






