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
    
    var frameSize = CGSize(width: 300, height: 350)
    
    init(coordinate: CLLocationCoordinate2D, title: String){
        self.coordinate = coordinate
        super.init()
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
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
    
    override func viewWillAppear(_ animated: Bool) {
        view.frame = CGRect(origin: CGPoint(x: view.frame.width/2 - frameSize.width/2, y: view.frame.height/2 - frameSize.height/2), size: frameSize)
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
    }
    
    func setupContent(){
        view.setRoundedBorders(radius: 10)
        locationLabel.textAlignment = .center
        contentView.addSubviewWithAnchors(locationLabel, top: contentView.topAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        
        let coordinateLabel = UILabel(text: coordinate.asString)
        contentView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, insets: flatInsets)
            .centerX(contentView.centerXAnchor)
        
        let createPlaceButton = UIButton().asTextButton("createPlace".localize())
        createPlaceButton.setRoundedBorders()
        createPlaceButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.addPlace(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(createPlaceButton, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let openCameraButton = UIButton().asTextButton("openCamera".localize())
        openCameraButton.setRoundedBorders()
        openCameraButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.openCamera(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(openCameraButton, top: createPlaceButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let addImageButton = UIButton().asTextButton("addImage".localize())
        addImageButton.setTitleColor(.systemBlue, for: .normal)
        addImageButton.setRoundedBorders()
        addImageButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.addImage(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addImageButton, top: openCameraButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let addAudioButton = UIButton().asTextButton("addAudio".localize())
        addAudioButton.setTitleColor(.systemBlue, for: .normal)
        addAudioButton.setRoundedBorders()
        addAudioButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.addAudio(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addAudioButton, top: addImageButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        
    }
    
}
