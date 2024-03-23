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
    func hideTrack()
    
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
    
    var locationMenuButton = UIButton().asIconButton("mappin.circle")
    
    //MainViewController
    var delegate : MainMenuDelegate? = nil
    
    func setup(){
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let insets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        
        addSubviewWithAnchors(locationMenuButton, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 20))
        locationMenuButton.menu = getLocationMenu()
        locationMenuButton.showsMenuAsPrimaryAction = true
        
        let trackMenuButton = UIButton().asIconButton("figure.walk.circle")
        addSubviewWithAnchors(trackMenuButton, top: topAnchor, leading: locationMenuButton.trailingAnchor, bottom: bottomAnchor, insets: insets)
        trackMenuButton.menu = getTrackingMenu()
        trackMenuButton.showsMenuAsPrimaryAction = true
        
        let crossButton = UIButton().asIconButton("plus.circle")
        addSubviewWithAnchors(crossButton, top: topAnchor, leading: trackMenuButton.trailingAnchor, bottom: bottomAnchor, insets: insets)
        crossButton.addAction(UIAction(){ action in
            AppState.shared.showCross = !AppState.shared.showCross
            self.delegate?.updateCross()
        }, for: .touchDown)
        
        let focusCurrentLocationButton = UIButton().asIconButton("record.circle")
        addSubviewWithAnchors(focusCurrentLocationButton, top: topAnchor, bottom: bottomAnchor, insets: insets)
            .centerX(centerXAnchor)
        focusCurrentLocationButton.addAction(UIAction(){ action in
            self.delegate?.focusUserLocation()
        }, for: .touchDown)
        
        let infoButton = UIButton().asIconButton("info.circle")
        addSubviewWithAnchors(infoButton, top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 10))
        infoButton.addAction(UIAction(){ action in
            self.delegate?.openInfo()
        }, for: .touchDown)
        
        let settingsButton = UIButton().asIconButton("gearshape")
        addSubviewWithAnchors(settingsButton, top: topAnchor, trailing: infoButton.leadingAnchor, bottom: bottomAnchor, insets: insets)
        settingsButton.menu = getSettingsMenu()
        settingsButton.showsMenuAsPrimaryAction = true
        
        let searchButton = UIButton().asIconButton("magnifyingglass")
        addSubviewWithAnchors(searchButton, top: topAnchor, trailing: settingsButton.leadingAnchor, bottom: bottomAnchor, insets: insets)
        searchButton.addAction(UIAction(){ action in
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
        return UIMenu(title: "", children: actions)
    }
    
    func getTrackingMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showTrackList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openTrackList()
        })
        actions.append(UIAction(title: "hideTrack".localize(), image: UIImage(systemName: "eraser")){ action in
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
        self.locationMenuButton.menu = self.getLocationMenu()
    }
    
}






