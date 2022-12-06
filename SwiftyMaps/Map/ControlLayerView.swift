/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol ControlLayerDelegate{
    func setMapType(_ type: MapType)
    func openPreloadMap()
    func openMapPreferences()
    
    func showPlaces(_ show: Bool)
    func openPlaceList()
    func openPlacePreferences()
    
    func startTracking()
    func openTrack(track: Track)
    func hideTrack()
    func openTrackList()
    func openTrackPreferences()
    
    func focusUserLocation()
    
    func openSearch()
    
    func openCamera()
    
    func openInfo()
    
    func addPlace()
    
}

class ControlLayerView: UIView {
    
    //MainViewController
    var delegate : ControlLayerDelegate? = nil
    
    var controlLine = UIView()
    var mapMenuControl = UIButton().setIcon("map")
    var placeMenuControl = UIButton().setIcon("mappin")
    var trackMenuControl = UIButton().setIcon("figure.walk")
    var crossControl = UIButton().setIcon("plus.circle")
    var currentTrackLine = CurrentTrackLine()
    var licenseView = UIView()
    
    func setup(){
        let layoutGuide = self.safeAreaLayoutGuide
        
        controlLine.backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        controlLine.layer.cornerRadius = 10
        controlLine.layer.masksToBounds = true
        addSubviewWithAnchors(controlLine, top: layoutGuide.topAnchor, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, insets: doubleInsets)
        
        controlLine.addSubviewWithAnchors(mapMenuControl, top: controlLine.topAnchor, leading: controlLine.leadingAnchor, bottom: controlLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 10 , bottom: 0, right: 0))
        mapMenuControl.menu = getMapMenu()
        mapMenuControl.showsMenuAsPrimaryAction = true
        
        controlLine.addSubviewWithAnchors(placeMenuControl, top: controlLine.topAnchor, leading: mapMenuControl.trailingAnchor, bottom: controlLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 30 , bottom: 0, right: 0))
        placeMenuControl.menu = getPlaceMenu()
        placeMenuControl.showsMenuAsPrimaryAction = true
        
        controlLine.addSubviewWithAnchors(trackMenuControl, top: controlLine.topAnchor, leading: placeMenuControl.trailingAnchor, bottom: controlLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 30 , bottom: 0, right: 0))
        trackMenuControl.menu = getTrackingMenu()
        trackMenuControl.showsMenuAsPrimaryAction = true
        
        let focusUserLocationControl = UIButton().setIcon("record.circle")
        controlLine.addSubviewWithAnchors(focusUserLocationControl, top: controlLine.topAnchor, bottom: controlLine.bottomAnchor)
            .centerX(controlLine.centerXAnchor)
        focusUserLocationControl.addTarget(self, action: #selector(focusUserLocation), for: .touchDown)
        
        let infoControl = UIButton().setIcon("info.circle")
        controlLine.addSubviewWithAnchors(infoControl, top: controlLine.topAnchor, trailing: controlLine.trailingAnchor, bottom: controlLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 10))
        infoControl.addTarget(self, action: #selector(openInfo), for: .touchDown)
        
        let openCameraControl = UIButton().setIcon("camera")
        controlLine.addSubviewWithAnchors(openCameraControl, top: controlLine.topAnchor, trailing: infoControl.leadingAnchor, bottom: controlLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 30))
        openCameraControl.addTarget(self, action: #selector(openCamera), for: .touchDown)
        
        let openSearchControl = UIButton().setIcon("magnifyingglass")
        controlLine.addSubviewWithAnchors(openSearchControl, top: controlLine.topAnchor, trailing: openCameraControl.leadingAnchor, bottom: controlLine.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 30))
        openSearchControl.addTarget(self, action: #selector(openSearch), for: .touchDown)
        
        currentTrackLine.setup()
        addSubviewWithAnchors(currentTrackLine, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, bottom: layoutGuide.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 2*defaultInset, bottom: 2*defaultInset, right: 2*defaultInset))
        
        crossControl.tintColor = UIColor.red
        addSubview(crossControl)
        crossControl.setAnchors(centerX: centerXAnchor, centerY: centerYAnchor)
        crossControl.menu = getCrossMenu()
        crossControl.showsMenuAsPrimaryAction = true
        crossControl.isHidden = !AppState.instance.showCross
        
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
        if AppState.instance.mapType == .carto{
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
        actions.append(UIAction(title: "preloadMaps".localize(), image: UIImage(systemName: "square.and.arrow.down")){ action in
            self.delegate?.openPreloadMap()
        })
        actions.append(UIAction(title: "preferences".localize(), image: UIImage(systemName: "gearshape")){ action in
            self.delegate?.openMapPreferences()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getPlaceMenu() -> UIMenu{
        var actions = Array<UIAction>()
        if AppState.instance.showPins{
            actions.append(UIAction(title: "hidePlaces".localize(), image: UIImage(systemName: "mappin.slash")){ action in
                self.delegate?.showPlaces(false)
                self.placeMenuControl.menu = self.getPlaceMenu()
            })
        }
        else{
            actions.append(UIAction(title: "showPlaces".localize(), image: UIImage(systemName: "mappin")){ action in
                self.delegate?.showPlaces(true)
                self.placeMenuControl.menu = self.getPlaceMenu()
                
            })
        }
        if AppState.instance.showCross{
            actions.append(UIAction(title: "hideCross".localize(), image: UIImage(systemName: "circle")){ action in
                AppState.instance.showCross = false
                self.crossControl.isHidden = true
                self.placeMenuControl.menu = self.getPlaceMenu()
            })
        }
        else{
            actions.append(UIAction(title: "showCross".localize(), image: UIImage(systemName: "plus.circle")){ action in
                AppState.instance.showCross = true
                self.crossControl.isHidden = false
                self.placeMenuControl.menu = self.getPlaceMenu()
                
            })
        }
        actions.append(UIAction(title: "showPlaceList".localize(), image: UIImage(systemName: "list.bullet")){ action in
            self.delegate?.openPlaceList()
        })
        actions.append(UIAction(title: "preferences".localize(), image: UIImage(systemName: "gearshape")){ action in
            self.delegate?.openPlacePreferences()
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getCrossMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "addPlace".localize(), image: UIImage(systemName: "mappin")){ action in
            self.delegate?.addPlace()
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
        actions.append(UIAction(title: "preferences".localize(), image: UIImage(systemName: "gearshape")){ action in
            self.delegate?.openTrackPreferences()
        })
        return UIMenu(title: "", children: actions)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            ($0 == controlLine || $0 == currentTrackLine || $0 is UIButton || $0 == licenseView) && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    // attribution link
    @objc func openOSMUrl() {
        UIApplication.shared.open(URL(string: "https://www.openstreetmap.org/copyright")!)
    }
    
    @objc func focusUserLocation(){
        delegate?.focusUserLocation()
    }
    
    @objc func openInfo(){
        delegate?.openInfo()
    }
    
    @objc func openCamera(){
        delegate?.openCamera()
    }
    
    @objc func openSearch(){
        delegate?.openSearch()
    }
    
    func activateCross(){
        crossControl.isHidden = false
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





