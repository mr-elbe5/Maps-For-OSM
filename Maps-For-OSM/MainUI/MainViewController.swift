/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVKit

class MainViewController: UIViewController {
    
    var mapView = MapView()
    var mainMenuView = MainMenuView()
    var actionMenuView = ActionMenuView()
    var mapMenuView = MapMenuView()
    var statusView = StatusView()
    var trackStatusView = TrackStatusView()
    var licenseView = UIView()
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setDefaultLocation()
    }
    
    func setupViews(){
        let layoutGuide = view.safeAreaLayoutGuide
        setupMapView(layoutGuide: layoutGuide)
        setupMainMenuView(layoutGuide: layoutGuide)
        setupActionMenuView(layoutGuide: layoutGuide)
        setupMapMenuView(layoutGuide: layoutGuide)
        setupLicenseView(layoutGuide: layoutGuide)
        setupStatusView(layoutGuide: layoutGuide)
        setupTrackStatusView(layoutGuide: layoutGuide)
        mapView.delegate = self
    }
    
    func setupMapView(layoutGuide: UILayoutGuide){
        view.addSubviewFilling(mapView)
        mapView.frame = view.bounds
        mapView.setupScrollView()
        mapView.setupTrackLayerView()
        mapView.setupCurrentLocationView()
        mapView.setupPlaceLayerView(controller: self)
        mapView.setupCrossView()
    }
    
    func setupMainMenuView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(mainMenuView, top: layoutGuide.topAnchor, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, insets: flatInsets)
        mainMenuView.setup()
        mainMenuView.delegate = self
    }
    
    func setupActionMenuView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(actionMenuView, top: mainMenuView.bottomAnchor, leading: layoutGuide.leadingAnchor, insets: defaultInsets)
        actionMenuView.setup()
        actionMenuView.delegate = self
    }
    
    func setupMapMenuView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(mapMenuView, top: actionMenuView.bottomAnchor, leading: layoutGuide.leadingAnchor, insets: defaultInsets)
        mapMenuView.setup()
        mapMenuView.delegate = self
    }
    
    func setupLicenseView(layoutGuide: UILayoutGuide){
        view.addSubviewWithAnchors(licenseView, trailing: layoutGuide.trailingAnchor, bottom: layoutGuide.bottomAnchor, insets: defaultInsets)
        
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
        link.addAction(UIAction(){ action in
            UIApplication.shared.open(URL(string: "https://www.openstreetmap.org/copyright")!)
        }, for: .touchDown)
        
        label = UILabel()
        label.textColor = .darkGray
        label.font = .preferredFont(forTextStyle: .footnote)
        licenseView.addSubviewWithAnchors(label, top: licenseView.topAnchor, leading: link.trailingAnchor, trailing: licenseView.trailingAnchor, bottom: licenseView.bottomAnchor, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: defaultInset))
        label.text = " contributors"
    }
    
    func setupStatusView(layoutGuide: UILayoutGuide){
        statusView.setup()
        view.addSubviewWithAnchors(statusView, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, bottom: licenseView.topAnchor, insets: flatInsets)
    }
    
    func setupTrackStatusView(layoutGuide: UILayoutGuide){
        trackStatusView.setup()
        trackStatusView.delegate = self
        view.addSubviewWithAnchors(trackStatusView, leading: layoutGuide.leadingAnchor, trailing: layoutGuide.trailingAnchor, bottom: licenseView.topAnchor, insets: flatInsets)
        trackStatusView.isHidden = true
    }
    
    func updateFollowTrack(){
        if Preferences.shared.followTrack{
            if TrackRecorder.isRecording{
                mapView.focusUserLocation()
            }
        }
    }
    
    func placeChanged(place: Place) {
        mapView.updatePlace(for: place)
    }
    
    func placesChanged() {
        mapView.updatePlaces()
    }
    
    func trackChanged() {
        mapView.trackLayerView.setNeedsDisplay()
    }
    
}

extension MainViewController: AppLoaderDelegate{
    
    func startLoading() {
        //todo
    }
    
    func appLoaded() {
        mapView.updatePlaces()
    }
    
    func appSaved() {
        //todo
    }
    
}



