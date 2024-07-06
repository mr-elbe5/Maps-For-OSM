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
    
    func openLocationList()
    func showLocations(_ show: Bool)
    
    func openTrackList()
    func importTrack()
    func hideTrack()
    
    func openImageList()
    func importImages()
    
    func focusUserLocation()
    
    func openSearch()
    
    func openICloud()
    func openPreferences()
    func refreshMap()
    func openPreloadTiles()
    func changeTileSource()
    func deleteAllTiles()
    func createBackup()
    func restoreBackup()
    
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
    
    func getSettingsMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "preferences".localize(), image: UIImage(systemName: "gearshape")){ action in
            self.delegate?.openPreferences()
        })
        actions.append(UIAction(title: "refreshMap".localize(), image: UIImage(systemName: "map")){ action in
            self.delegate?.refreshMap()
        })
        actions.append(UIAction(title: "preloadTiles".localize(), image: UIImage(systemName: "map")){ action in
            self.delegate?.openPreloadTiles()
        })
        actions.append(UIAction(title: "changeTileSource".localize(), image: UIImage(systemName: "map")){ action in
            self.delegate?.changeTileSource()
        })
        actions.append(UIAction(title: "deleteAllTiles".localize(), image: UIImage(systemName: "map")?.withTintColor(.red, renderingMode: .alwaysOriginal)){ action in
            self.delegate?.deleteAllTiles()
        })
        actions.append(UIAction(title: "createBackup".localize(), image: UIImage(systemName: "tray")){ action in
            self.delegate?.createBackup()
        })
        actions.append(UIAction(title: "restoreBackup".localize(), image: UIImage(systemName: "tray")){ action in
            self.delegate?.restoreBackup()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func updateLocationMenu(){
        self.viewMenuButton.menu = self.getViewMenu()
    }
    
}






