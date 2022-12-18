/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol MainMenuDelegate: MapPositionDelegate{
    
    func refreshMap()
    func openPreloadMap()
    
    func showLocations(_ show: Bool)
    func openLocationList()
    
    func startTracking()
    func openTrack(track: Track)
    func hideTrack()
    func openTrackList()
    
    func updateCross()
    func focusUserLocation()
    
    func openSearch()
    
    func openPreferences()
    
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
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        addSubviewFilling(stackView, insets: defaultInsets)
        
        stackView.addArrangedSubview(mapMenuControl)
        mapMenuControl.menu = getMapMenu()
        mapMenuControl.showsMenuAsPrimaryAction = true
        
        stackView.addArrangedSubview(locationMenuControl)
        locationMenuControl.menu = getLocationMenu()
        locationMenuControl.showsMenuAsPrimaryAction = true
        
        stackView.addArrangedSubview(trackMenuControl)
        trackMenuControl.menu = getTrackingMenu()
        trackMenuControl.showsMenuAsPrimaryAction = true
        
        let crossControl = UIButton().asIconButton("plus.circle")
        stackView.addArrangedSubview(crossControl)
        crossControl.addTarget(self, action: #selector(toggleCross), for: .touchDown)
        
        let focusUserLocationControl = UIButton().asIconButton("record.circle")
        stackView.addArrangedSubview(focusUserLocationControl)
        focusUserLocationControl.addTarget(self, action: #selector(focusUserLocation), for: .touchDown)
        
        let cameraControl = UIButton().asIconButton("camera")
        stackView.addArrangedSubview(cameraControl)
        cameraControl.menu = getCameraMenu()
        cameraControl.showsMenuAsPrimaryAction = true
        
        let searchControl = UIButton().asIconButton("magnifyingglass")
        stackView.addArrangedSubview(searchControl)
        searchControl.addTarget(self, action: #selector(openSearch), for: .touchDown)
        
        let preferencesControl = UIButton().asIconButton("gearshape")
        stackView.addArrangedSubview(preferencesControl)
        preferencesControl.addTarget(self, action: #selector(openPreferences), for: .touchDown)
        
        let infoControl = UIButton().asIconButton("info.circle")
        stackView.addArrangedSubview(infoControl)
        infoControl.addTarget(self, action: #selector(openInfo), for: .touchDown)
        
    }
    
    func getMapMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "refreshMap".localize(), image: UIImage(systemName: "arrow.clockwise")){ action in
            self.delegate?.refreshMap()
        })
        actions.append(UIAction(title: "preloadMaps".localize(), image: UIImage(systemName: "square.and.arrow.down")){ action in
            self.delegate?.openPreloadMap()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getLocationMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if AppState.shared.showLocations{
            actions.append(UIAction(title: "hideLocations".localize(), image: UIImage(systemName: "mappin.slash")){ action in
                self.delegate?.showLocations(false)
                self.locationMenuControl.menu = self.getLocationMenu()
            })
        }
        else{
            actions.append(UIAction(title: "showLocations".localize(), image: UIImage(systemName: "mappin")){ action in
                self.delegate?.showLocations(true)
                self.locationMenuControl.menu = self.getLocationMenu()
                
            })
        }
        actions.append(UIAction(title: "showLocationList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openLocationList()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getTrackingMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if let track = TrackRecorder.track{
            actions.append(UIAction(title: "showCurrentTrack".localize(), image: UIImage(systemName: "figure.walk")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)){ action in
                self.delegate?.openTrack(track: track)
                self.trackMenuControl.menu = self.getTrackingMenu()
            })
        }
        else{
            actions.append(UIAction(title: "startRecording".localize(), image: UIImage(systemName: "figure.walk")){ action in
                self.delegate?.startTracking()
                self.trackMenuControl.menu = self.getTrackingMenu()
            })
            
        }
        if TrackPool.visibleTrack != nil {
            actions.append(UIAction(title: "hideTrack".localize(), image: UIImage(systemName: "eye.slash")){ action in
                self.delegate?.hideTrack()
                self.trackMenuControl.menu = self.getTrackingMenu()
            })
        }
        actions.append(UIAction(title: "showTrackList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openTrackList()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getCameraMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "addPhoto".localize(), image: UIImage(systemName: "camera")){ action in
            self.delegate?.addPhotoAtCurrentPosition()
        })
        actions.append(UIAction(title: "addVideo".localize(), image: UIImage(systemName: "video")){ action in
            self.delegate?.addVideoAtCurrentPosition()
        })
        actions.append(UIAction(title: "addAudio".localize(), image: UIImage(systemName: "mic")){ action in
            self.delegate?.addAudioAtCurrentPosition()
        })
        return UIMenu(title: "", children: actions)
    }
    
    @objc func toggleCross(){
        AppState.shared.showCross = !AppState.shared.showCross
        delegate?.updateCross()
    }
    
    @objc func focusUserLocation(){
        delegate?.focusUserLocation()
    }
    
    @objc func openInfo(){
        delegate?.openInfo()
    }
    
    @objc func openPreferences(){
        delegate?.openPreferences()
    }
    
    @objc func openSearch(){
        delegate?.openSearch()
    }
    
}






