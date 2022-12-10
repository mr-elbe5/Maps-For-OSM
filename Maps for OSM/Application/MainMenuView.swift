/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol MainMenuDelegate: MapPositionDelegate{
    
    func setMapType(_ type: MapType)
    func openPreloadMap()
    
    func showLocations(_ show: Bool)
    func openLocationList()
    
    func startTracking()
    func openTrack(track: Track)
    func hideTrack()
    func openTrackList()
    
    func updateCross()
    func focusUserLocation()
    func refreshMap()
    
    func openSearch()
    
    func openPreferences()
    
    func openInfo()
    
}

class MainMenuView: UIView {
    
    //MainViewController
    var delegate : MainMenuDelegate? = nil
    
    var iconLine = UIView()
    var mapMenuControl = UIButton().asIconButton("map")
    var locationMenuControl = UIButton().asIconButton("mappin")
    var trackMenuControl = UIButton().asIconButton("figure.walk")
    var currentTrackLine = CurrentTrackLine()
    var licenseView = UIView()
    
    func setup(){
        let layoutGuide = self.safeAreaLayoutGuide
        
        iconLine.backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        iconLine.layer.cornerRadius = 10
        iconLine.layer.masksToBounds = true
        addSubviewWithAnchors(iconLine, top: layoutGuide.topAnchor, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, insets: doubleInsets)
        
        iconLine.addSubviewWithAnchors(mapMenuControl, top: iconLine.topAnchor, leading: iconLine.leadingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 10 , bottom: 0, right: 0))
        mapMenuControl.menu = getMapMenu()
        mapMenuControl.showsMenuAsPrimaryAction = true
        
        iconLine.addSubviewWithAnchors(locationMenuControl, top: iconLine.topAnchor, leading: mapMenuControl.trailingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 20 , bottom: 0, right: 0))
        locationMenuControl.menu = getLocationMenu()
        locationMenuControl.showsMenuAsPrimaryAction = true
        
        iconLine.addSubviewWithAnchors(trackMenuControl, top: iconLine.topAnchor, leading: locationMenuControl.trailingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 20 , bottom: 0, right: 0))
        trackMenuControl.menu = getTrackingMenu()
        trackMenuControl.showsMenuAsPrimaryAction = true
        
        let focusUserLocationControl = UIButton().asIconButton("record.circle")
        iconLine.addSubviewWithAnchors(focusUserLocationControl, top: iconLine.topAnchor, bottom: iconLine.bottomAnchor)
            .centerX(iconLine.centerXAnchor)
        focusUserLocationControl.addTarget(self, action: #selector(focusUserLocation), for: .touchDown)
        
        let crossControl = UIButton().asIconButton("plus.circle")
        iconLine.addSubviewWithAnchors(crossControl, top: iconLine.topAnchor, trailing: focusUserLocationControl.leadingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 20))
        crossControl.addTarget(self, action: #selector(toggleCross), for: .touchDown)
        
        let infoControl = UIButton().asIconButton("info.circle")
        iconLine.addSubviewWithAnchors(infoControl, top: iconLine.topAnchor, trailing: iconLine.trailingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 10))
        infoControl.addTarget(self, action: #selector(openInfo), for: .touchDown)
        
        let preferencesControl = UIButton().asIconButton("gearshape")
        iconLine.addSubviewWithAnchors(preferencesControl, top: iconLine.topAnchor, trailing: infoControl.leadingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 10))
        preferencesControl.addTarget(self, action: #selector(openPreferences), for: .touchDown)
        
        let searchControl = UIButton().asIconButton("magnifyingglass")
        iconLine.addSubviewWithAnchors(searchControl, top: iconLine.topAnchor, trailing: preferencesControl.leadingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 20))
        searchControl.addTarget(self, action: #selector(openSearch), for: .touchDown)
        
        let cameraControl = UIButton().asIconButton("camera")
        iconLine.addSubviewWithAnchors(cameraControl, top: iconLine.topAnchor, trailing: searchControl.leadingAnchor, bottom: iconLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 20))
        cameraControl.menu = getCameraMenu()
        cameraControl.showsMenuAsPrimaryAction = true
        
        currentTrackLine.setup()
        addSubviewWithAnchors(currentTrackLine, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, bottom: layoutGuide.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 2*defaultInset, bottom: 2*defaultInset, right: 2*defaultInset))
        
        addSubviewWithAnchors(licenseView, top: currentTrackLine.bottomAnchor, trailing: layoutGuide.trailingAnchor, insets: UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: 0, right: defaultInset))
        
        var label = UILabel()
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewWithAnchors(label, top: licenseView.topAnchor, leading: licenseView.leadingAnchor, bottom: licenseView.bottomAnchor)
        label.text = "© "
        
        let link = UIButton()
        link.setTitleColor(.systemBlue, for: .normal)
        link.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewWithAnchors(link, top: licenseView.topAnchor, leading: label.trailingAnchor, bottom: licenseView.bottomAnchor)
        link.setTitle("OpenStreetMap", for: .normal)
        link.addTarget(self, action: #selector(openOSMUrl), for: .touchDown)
        
        label = UILabel()
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewWithAnchors(label, top: licenseView.topAnchor, leading: link.trailingAnchor, trailing: licenseView.trailingAnchor, bottom: licenseView.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: defaultInset))
        label.text = " contributors"
    }
    
    func getMapMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if AppState.shared.mapType == .carto{
            actions.append(UIAction(title: "topoMapType".localize(), image: UIImage(systemName: "map.fill")){ action in
                self.delegate?.setMapType(.topo)
                self.mapMenuControl.menu = self.getMapMenu()
            })
        }
        else{
            actions.append(UIAction(title: "cartoMapType".localize(), image: UIImage(systemName: "map")){ action in
                self.delegate?.setMapType(.carto)
                self.mapMenuControl.menu = self.getMapMenu()
            })
        }
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
        if AppState.shared.showPins{
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
        if Tracks.visibleTrack != nil {
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            ($0 == iconLine || $0 == currentTrackLine || $0 is UIButton || $0 == licenseView) && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    // attribution link
    @objc func openOSMUrl() {
        UIApplication.shared.open(URL(string: "https://www.openstreetmap.org/copyright")!)
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
    
    func startTrackInfo(){
        currentTrackLine.startInfo()
        currentTrackLine.updatePauseResumeButton()
    }
    
    func pauseTrackInfo(){
        currentTrackLine.updatePauseResumeButton()
    }
    
    func resumeTrackInfo(){
        currentTrackLine.updatePauseResumeButton()
    }
    
    func updateTrackInfo(){
        currentTrackLine.updateInfo()
    }
    
    func stopTrackInfo(){
        currentTrackLine.stopInfo()
    }
    
    func startTrackControl(){
        trackMenuControl.menu = getTrackingMenu()
        startTrackInfo()
    }
    
    func stopTrackControl(){
        trackMenuControl.menu = getTrackingMenu()
        stopTrackInfo()
    }
    
}

class MapControlLine : UIView{
    
    func setup(){
        backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
}





