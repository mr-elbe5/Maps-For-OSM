//
//  MapViewController.swift
//
//  Created by Michael Rönnau on 13.06.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import UIKit
import MapKit
import SwiftyIOSViewExtensions

class MainViewController: MapViewController {
    
    var menuView = UIView()
    var statusView = UIView()
    
    var isTracking : Bool = false

    override func loadView() {
        super.loadView()
        LocationService.shared.checkRunning()
        let guide = view.safeAreaLayoutGuide
        view.addSubview(menuView)
        menuView.setAnchors()
                .leading(guide.leadingAnchor, inset: .zero)
                .top(guide.topAnchor, inset: .zero)
                .trailing(guide.trailingAnchor, inset: .zero)
        menuView.backgroundColor = .black
        fillMenu()
        mapView.mapType = .standard
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isPitchEnabled = false
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.setAnchors()
                .leading(guide.leadingAnchor, inset: .zero)
                .top(menuView.bottomAnchor, inset: 1)
                .trailing(guide.trailingAnchor, inset: .zero)
        view.addSubview(statusView)
        fillStatus()
        statusView.setAnchors()
                .leading(guide.leadingAnchor, inset: .zero)
                .top(mapView.bottomAnchor, inset: .zero)
                .trailing(guide.trailingAnchor, inset: .zero)
            .bottom(guide.bottomAnchor, inset: .zero)
        menuView.backgroundColor = .black
        applySettings()
    }
    
    func applySettings(){
        mapView.showsUserLocation = Settings.instance.showUserLocation
        setMapType(Settings.instance.mapTypeName.getMapType())
    }
    
    func updateSettings(){
        Settings.instance.showUserLocation = mapView.showsUserLocation
    }

    // menu

    var styleButton : MenuButton!
    var tourButton : MenuButton!
    var pinButton : MenuButton!
    var cameraButton : MenuButton!
    var settingsButton : MenuButton!
    var transferButton : MenuButton!
    var infoButton : MenuButton!

    var statusLabel : UILabel!
    var centerButton : IconButton!
    var refreshButton : IconButton!

    func fillMenu() {
        styleButton = MenuButton(icon: "map", menu: getStyleMenu())
        menuView.addSubview(styleButton)
        tourButton = MenuButton(icon: "figure.walk", menu: getTourMenu())
        menuView.addSubview(tourButton)
        pinButton = MenuButton(icon: "mappin", menu: getPinMenu())
        menuView.addSubview(pinButton)
        cameraButton = MenuButton(icon: "camera", menu: getCameraMenu())
        menuView.addSubview(cameraButton)
        settingsButton = MenuButton(icon: "slider.horizontal.3", menu: getSettingsMenu())
        settingsButton.showsMenuAsPrimaryAction = true
        menuView.addSubview(settingsButton)
        transferButton = MenuButton(icon: "arrow.up.arrow.down", menu: getTransferMenu())
        transferButton.showsMenuAsPrimaryAction = true
        menuView.addSubview(transferButton)
        infoButton = MenuButton(icon: "info.circle", menu: getInfoMenu())
        menuView.addSubview(infoButton)

        styleButton.setAnchors()
                .top(menuView.topAnchor, inset: defaultInset)
                .leading(menuView.leadingAnchor, inset: defaultInset)
                .bottom(menuView.bottomAnchor, inset: defaultInset)

        tourButton.setAnchors()
                .top(menuView.topAnchor, inset: defaultInset)
                .centerX(menuView.centerXAnchor)
                .bottom(menuView.bottomAnchor, inset: defaultInset)
        pinButton.setAnchors()
                .top(menuView.topAnchor, inset: defaultInset)
                .trailing(tourButton.leadingAnchor, inset: 2 * defaultInset)
                .bottom(menuView.bottomAnchor, inset: defaultInset)
        cameraButton.setAnchors()
                .top(menuView.topAnchor, inset: defaultInset)
                .leading(tourButton.trailingAnchor, inset: 2 * defaultInset)
                .bottom(menuView.bottomAnchor, inset: defaultInset)

        infoButton.setAnchors()
                .top(menuView.topAnchor, inset: defaultInset)
                .trailing(menuView.trailingAnchor, inset: defaultInset)
                .bottom(menuView.bottomAnchor, inset: defaultInset)
        transferButton.setAnchors()
                .top(menuView.topAnchor, inset: defaultInset)
                .trailing(infoButton.leadingAnchor, inset: 2 * defaultInset)
                .bottom(menuView.bottomAnchor, inset: defaultInset)
        settingsButton.setAnchors()
                .top(menuView.topAnchor, inset: defaultInset)
                .trailing(transferButton.leadingAnchor, inset: 2 * defaultInset)
                .bottom(menuView.bottomAnchor, inset: defaultInset)
    }

    func getStyleMenu() -> UIMenu{
        let standardMapAction = UIAction(title: "defaultMapStyle".localize()) { action in
            self.setMapType(StandardMapType.instance)
        }
        let osmMapAction = UIAction(title: "openStreetMapStyle".localize()) { action in
            self.setMapType(OpenStreetMapType.instance)
        }
        let topoMapAction = UIAction(title: "openTopoMapStyle".localize()) { action in
            self.setMapType(OpenTopoMapType.instance)
        }
        let satelliteAction = UIAction(title: "satelliteMapStyle".localize()) { action in
            self.setMapType(SatelliteMapType.instance)
        }
        return UIMenu(title: "", children: [standardMapAction, osmMapAction, topoMapAction, satelliteAction])
    }

    func getTourMenu() -> UIMenu {
        let title = self.isTracking ? "stop" : "start"
        let img = isTracking ? UIImage(systemName: "figure.stand") : UIImage(systemName: "figure.walk")
        let toggleAction = UIAction(title: title.localize(), image: img) { action in
            self.isTracking = !self.isTracking
            self.tourButton.menu = self.getTourMenu()
        }
        return UIMenu(title: "", children: [toggleAction])
    }
    
    func getPinMenu() -> UIMenu{
        let isShowingPins = Settings.instance.showPins
        let title = isShowingPins ? "hidePins" : "showPins"
        let img = isShowingPins ? UIImage(systemName: "mappin.slash") : UIImage(systemName: "mappin")
        let toggleAction = UIAction(title: title.localize(), image: img) { action in
            Settings.instance.showPins = !Settings.instance.showPins
            self.pinButton.menu = self.getPinMenu()
            
        }
        let addAction = UIAction(title: "addPin".localize(), image: UIImage(systemName: "mappin.and.ellipse")) { action in
            
        }
        return UIMenu(title: "", children: [toggleAction, addAction])
    }

    func getCameraMenu() -> UIMenu{
        let addPhoto = UIAction(title: "addPhoto".localize(), image: UIImage(systemName: "camera")) { action in

        }
        return UIMenu(title: "", children: [addPhoto])
    }

    func getSettingsMenu() -> UIMenu{
        let lastPosImage = Settings.instance.startWithLastPosition ? "checkmark" : "nosign"
        let lastPosAction = UIAction(title: "startWithLastPosition".localize(), image: UIImage(systemName: lastPosImage)) { action in
            Settings.instance.startWithLastPosition = !Settings.instance.startWithLastPosition
            self.settingsButton.menu = self.getSettingsMenu()
        }
        let userLocImage = Settings.instance.showUserLocation ? "checkmark" : "nosign"
        let userLocAction = UIAction(title: "showUserLocation".localize(), image: UIImage(systemName: userLocImage)) { action in
            Settings.instance.showUserLocation = !Settings.instance.showUserLocation
            self.settingsButton.menu = self.getSettingsMenu()
        }
        return UIMenu(title: "", children: [lastPosAction, userLocAction])

    }
    
    func getTransferMenu() -> UIMenu{
        let exportAction = UIAction(title: "export".localize(), image: UIImage(systemName: "arrow.up")) { action in

        }
        let importAction = UIAction(title: "import".localize(), image: UIImage(systemName: "arrow.down")) { action in

        }
        return UIMenu(title: "", children: [exportAction, importAction])

    }

    func getInfoMenu() -> UIMenu{
        let appAction = UIAction(title: "appInfo".localize(), image: UIImage(systemName: "app")) { action in

        }
        let mapAction = UIAction(title: "mapInfo".localize(), image: UIImage(systemName: "map")) { action in

        }
        return UIMenu(title: "", children: [appAction, mapAction])

    }

    func fillStatus() {
        statusLabel = UILabel()
        statusLabel.textColor = .white
        statusView.addSubview(statusLabel)
        centerButton = IconButton(icon: "smallcircle.fill.circle", tintColor: .white)
        centerButton.addTarget(self, action: #selector(centerMap), for: .touchDown)
        statusView.addSubview(centerButton)
        refreshButton = IconButton(icon: "arrow.triangle.2.circlepath", tintColor: .white)
        refreshButton.addTarget(self, action: #selector(refreshMap), for: .touchDown)
        statusView.addSubview(refreshButton)

        statusLabel.setAnchors()
                .top(statusView.topAnchor, inset: defaultInset)
                .centerX(statusView.centerXAnchor)
                .bottom(statusView.bottomAnchor)
        centerButton.setAnchors()
                .top(statusView.topAnchor, inset: defaultInset)
                .leading(statusLabel.trailingAnchor, inset: defaultInset)
                .bottom(statusView.bottomAnchor)
        refreshButton.setAnchors()
                .top(statusView.topAnchor, inset: defaultInset)
                .trailing(statusView.trailingAnchor, inset: defaultInset)
                .bottom(statusView.bottomAnchor)
    }
    
    func updatePositionLabel(){
        LocationService.shared.lookUpCurrentLocation()
        statusLabel.text = LocationService.shared.getLocationDescription()
    }
    
    @objc func centerMap(){
        if let loc = LocationService.shared.getLocation(){
            mapView.centerToLocation(loc)
        }
    }

    @objc func refreshMap(){
        if let renderer = tileOverlayRenderer{
            renderer.reloadData()
        }
        else{
            mapView.setNeedsLayout()
        }
    }
    
    override func locationDidChange(location: Location){
        super.locationDidChange(location: location)
        updatePositionLabel()
        if isTracking{
            mapView.centerToLocation(location)
        }
    }

}