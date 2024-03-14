/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol UserLocationDelegate{
    func addPlaceAtUserLocation()
    func openCameraAtUserLocation()
    func addImageAtUserLocation()
    func addAudioAtUserLocation()
}

/*
 func getUserLocationMenu() -> UIMenu{
     var actions = Array<UIAction>()
     actions.append(UIAction(title: "addPlace".localize()){ action in
         self.delegate?.addPlaceAtCurrentPosition()
     })
     actions.append(UIAction(title: "openCamera".localize()){ action in
         self.delegate?.openCameraAtCurrentPosition()
     })
     actions.append(UIAction(title: "addImage".localize()){ action in
         self.delegate?.addImageAtCurrentPosition()
     })
     actions.append(UIAction(title: "addAudio".localize()){ action in
         self.delegate?.addAudioAtCurrentPosition()
     })
     return UIMenu(title: "currentPosition".localize(), children: actions)
 }
 */

class UserLocationViewController: PopupScrollViewController{
    
    var delegate: UserLocationDelegate? = nil
    
    var coordinate: CLLocationCoordinate2D
    
    let locationLabel = UILabel(text: "")
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "userLocation".localize()
        super.loadView()
        scrollView.setupVertical()
        setupContent()
    }
    
    override func viewDidLoad() {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        LocationService.shared.getPlacemark(for: location){ placemark in
            var str : String
            if let placemark = placemark{
                str = placemark.locationString
            } else{
                str = location.coordinate.asString
            }
            self.locationLabel.text = str
        }
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
    }
    
    func setupContent(){
        var header = UILabel(header: "locationData".localize())
        contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        contentView.addSubviewWithAnchors(locationLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: coordinate.asString)
        contentView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
    }
    
}


