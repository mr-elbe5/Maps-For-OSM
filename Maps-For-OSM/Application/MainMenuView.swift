/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol MainMenuDelegate{
    
    func openLocationList()
    func showLocations(_ show: Bool)
    func openTrackList()
    
    func updateCross()
    func focusUserLocation()
    
    func openSearch()
    
    func openPreferences()
    func refreshMap()
    func openPreloadTiles()
    func changeTileSource()
    func deleteAllTiles()
    func exportImagesToPhotoLibrary()
    func importFromPhotoLibrary()
    func createBackup()
    func restoreBackup()
    
    func openInfo()
    
}

class MainMenuView: UIView {
    
    //MainViewController
    var delegate : MainMenuDelegate? = nil
    
    var mapMenuControl = UIButton().asIconButton("map")
    var locationMenuControl = UIButton().asIconButton("mappin")
    var trackMenuControl = UIButton().asIconButton("figure.walk")
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        addSubviewWithAnchors(locationMenuControl, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        locationMenuControl.menu = getLocationMenu()
        locationMenuControl.showsMenuAsPrimaryAction = true
        
        let crossControl = UIButton().asIconButton("plus.circle")
        addSubviewWithAnchors(crossControl, top: topAnchor, trailing: centerXAnchor, bottom: bottomAnchor, insets: defaultInsets)
        crossControl.addAction(UIAction(){ action in
            AppState.shared.showCross = !AppState.shared.showCross
            self.delegate?.updateCross()
        }, for: .touchDown)
        
        let focusUserLocationControl = UIButton().asIconButton("record.circle")
        addSubviewWithAnchors(focusUserLocationControl, top: topAnchor, leading: centerXAnchor, bottom: bottomAnchor, insets: defaultInsets)
        focusUserLocationControl.addAction(UIAction(){ action in
            self.delegate?.focusUserLocation()
        }, for: .touchDown)
        
        let infoControl = UIButton().asIconButton("info.circle")
        addSubviewWithAnchors(infoControl, top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        infoControl.addAction(UIAction(){ action in
            self.delegate?.openInfo()
        }, for: .touchDown)
        
        let settingsControl = UIButton().asIconButton("gearshape")
        addSubviewWithAnchors(settingsControl, top: topAnchor, trailing: infoControl.leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        settingsControl.menu = getSettingsMenu()
        settingsControl.showsMenuAsPrimaryAction = true
        
        let searchControl = UIButton().asIconButton("magnifyingglass")
        addSubviewWithAnchors(searchControl, top: topAnchor, trailing: settingsControl.leadingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        searchControl.addAction(UIAction(){ action in
            self.delegate?.openSearch()
        }, for: .touchDown)
        
    }
    
    func getLocationMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showPlaceList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openLocationList()
        })
        if AppState.shared.showLocations{
            actions.append(UIAction(title: "hidePlaces".localize(), image: UIImage(systemName: "mappin.slash")){ action in
                self.delegate?.showLocations(false)
                self.updateLocationMenu()
            })
        }
        else{
            actions.append(UIAction(title: "showPlaces".localize(), image: UIImage(systemName: "mappin")){ action in
                self.delegate?.showLocations(true)
                self.updateLocationMenu()
                
            })
        }
        actions.append(UIAction(title: "showTrackList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openTrackList()
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
        actions.append(UIAction(title: "exportImagesToPhotoLibrary".localize(), image: UIImage(systemName: "photo.stack")){ action in
            self.delegate?.exportImagesToPhotoLibrary()
            
        })
        actions.append(UIAction(title: "importFromPhotoLibrary".localize(), image: UIImage(systemName: "photo.stack")){ action in
            self.delegate?.importFromPhotoLibrary()
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
        self.locationMenuControl.menu = self.getLocationMenu()
    }
    
}






