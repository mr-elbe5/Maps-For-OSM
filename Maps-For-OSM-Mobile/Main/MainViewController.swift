/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class MainViewController: NavViewController {
    
    var mapView = MapView()
    var topMenuView = TopMenuView()
    var actionMenuView = ActionMenuView()
    var mapMenuView = MapMenuView()
    var statusView = StatusView()
    var licenseView = UIView()
    
    var cancelAlert: UIAlertController? = nil
    
    var startCoordinate: CLLocationCoordinate2D? = nil
    
    override func updateNavigationItems() {
        view.backgroundColor = .black
        // left
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "locations".localize(), image: UIImage(systemName: "mappin"), primaryAction: UIAction(){ action in
            let controller = LocationListViewController()
            controller.locationDelegate = self
            controller.trackDelegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "tracks".localize(), image: UIImage(systemName: "figure.walk"), primaryAction: UIAction(){ action in
            let controller = TrackListViewController()
            controller.locationDelegate = self
            controller.trackDelegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "images".localize(), image: UIImage(systemName: "photo"), primaryAction: UIAction(){ action in
            let controller = ImageListViewController()
            controller.images = AppData.shared.locations.images
            controller.locationDelegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.leadingItemGroups = groups
        
        //right
        groups = Array<UIBarButtonItemGroup>()
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "cloud".localize(), image: UIImage(systemName: "cloud"), primaryAction: UIAction(){ action in
            let controller = ICloudViewController()
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "settings".localize(), image: UIImage(systemName: "gearshape"), primaryAction: UIAction(){ action in
            let controller = SettingsViewController()
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            UIApplication.shared.open(URL(string: "infoURL".localize())!)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCoordinate = AppState.shared.coordinate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let coord = startCoordinate{
            AppState.shared.coordinate = coord
            mapView.setStartLocation()
            startCoordinate = nil
        }
        if let trackRecorder = TrackRecorder.instance, trackRecorder.interrupted{
            showDecide(title: "interruptedTrackFound".localize(), text: "shouldResumeInterruptedTrack".localize(), onYes: {
                trackRecorder.isRecording = true
                trackRecorder.interrupted = false
                self.actionMenuView.updateTrackingButton()
            }, onNo:{
                TrackRecorder.instance = nil
            })
        }
    }
    
    override func loadSubviews(guide: UILayoutGuide) {
        setupMapView(guide: guide)
        setupTopMenuView(guide: guide)
        setupActionMenuView(guide: guide)
        setupMapMenuView(guide: guide)
        setupLicenseView(guide: guide)
        setupStatusView(guide: guide)
        mapView.delegate = self
    }
    
    func setupMapView(guide: UILayoutGuide){
        mapMenuView.setBackground(.transparentColor)
        view.addSubviewWithAnchors(mapView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor)
        mapView.setupScrollView()
        mapView.setupTrackLayerView()
        mapView.setupCurrentLocationView()
        mapView.setupLocationLayerView(controller: self)
        mapView.setupCrossView()
    }
    
    func setupTopMenuView(guide: UILayoutGuide){
        topMenuView.setBackground(.transparentColor)
        view.addSubviewWithAnchors(topMenuView, top: guide.topAnchor, insets: defaultInsets).centerX(guide.centerXAnchor)
        topMenuView.setup()
        topMenuView.delegate = self
    }
    
    func setupActionMenuView(guide: UILayoutGuide){
        actionMenuView.setBackground(.transparentColor)
        view.addSubviewWithAnchors(actionMenuView, top: guide.topAnchor, leading: guide.leadingAnchor, insets: defaultInsets)
        actionMenuView.setup()
        actionMenuView.delegate = self
    }
    
    func setupMapMenuView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(mapMenuView, top: guide.topAnchor, trailing: guide.trailingAnchor, insets: defaultInsets)
        mapMenuView.setup()
        mapMenuView.delegate = self
    }
    
    func setupLicenseView(guide: UILayoutGuide){
        view.addSubviewWithAnchors(licenseView, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: defaultInsets)
        
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
    
    func setupStatusView(guide: UILayoutGuide){
        statusView.setBackground(.transparentColor)
        statusView.setup()
        view.addSubviewWithAnchors(statusView, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: licenseView.topAnchor, insets: UIEdgeInsets(top: 0, left: defaultInset, bottom: 0, right: defaultInset))
        statusView.delegate = self
    }
    
}



