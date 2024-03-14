/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

protocol LocationViewDelegate{
    func addPlace(at coordinate: CLLocationCoordinate2D)
    func openCamera(at coordinate: CLLocationCoordinate2D)
    func addImage(at coordinate: CLLocationCoordinate2D)
    func addAudio(at coordinate: CLLocationCoordinate2D)
}

class LocationViewController: PopupScrollViewController{
    
    var delegate: LocationViewDelegate? = nil
    
    var coordinate: CLLocationCoordinate2D
    
    let locationLabel = UILabel(text: "")
    
    init(coordinate: CLLocationCoordinate2D, title: String){
        self.coordinate = coordinate
        super.init()
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "crossLocation".localize()
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
        let header = UILabel(header: "position".localize())
        contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        contentView.addSubviewWithAnchors(locationLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: coordinate.asString)
        contentView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        let createPlaceButton = UIButton()
        createPlaceButton.setTitle("createPlace".localize(), for: .normal)
        createPlaceButton.setTitleColor(.systemBlue, for: .normal)
        createPlaceButton.addAction(UIAction(){ action in
            self.delegate?.addPlace(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(createPlaceButton, top: coordinateLabel.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let openCameraButton = UIButton()
        openCameraButton.setTitle("openCamera".localize(), for: .normal)
        openCameraButton.setTitleColor(.systemBlue, for: .normal)
        openCameraButton.addAction(UIAction(){ action in
            self.delegate?.openCamera(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(openCameraButton, top: createPlaceButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let addImageButton = UIButton()
        addImageButton.setTitle("addImage".localize(), for: .normal)
        addImageButton.setTitleColor(.systemBlue, for: .normal)
        addImageButton.addAction(UIAction(){ action in
            self.delegate?.addImage(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addImageButton, top: openCameraButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        let addAudioButton = UIButton()
        addAudioButton.setTitle("addAudio".localize(), for: .normal)
        addAudioButton.setTitleColor(.systemBlue, for: .normal)
        addAudioButton.addAction(UIAction(){ action in
            self.delegate?.addAudio(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addAudioButton, top: addImageButton.bottomAnchor, bottom: contentView.bottomAnchor, insets: doubleInsets)
        .centerX(contentView.centerXAnchor)
        
        
    }
    
}
