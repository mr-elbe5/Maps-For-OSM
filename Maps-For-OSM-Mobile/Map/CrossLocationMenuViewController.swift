/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class CrossLocationMenuViewController: PopupScrollViewController{
    
    var coordinate: CLLocationCoordinate2D
    
    let locationLabel = UILabel(text: "")
    
    var frameSize = CGSize(width: 300, height: 350)
    
    var delegate: ActionMenuDelegate? = nil
    
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
        view.backgroundColor = .systemBackground
        scrollView.backgroundColor = .systemBackground
        scrollView.setupVertical()
        setupContent()
    }
    
    override func setupHeaderView(headerView: UIView){
        if let title = title{
            let label = UILabel(header: title)
            headerView.addSubviewWithAnchors(label, top: headerView.topAnchor, insets: defaultInsets)
                .centerX(headerView.centerXAnchor)
            titleLabel = label
        }
        headerView.addSubviewWithAnchors(closeButton, top: headerView.topAnchor, trailing: headerView.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        closeButton.addAction(UIAction(){ action in
            self.dismiss(animated: true)
        }, for: .touchDown)
        closeButton.tintColor = .label
    }
    
    override func viewDidLoad() {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLPlacemark.getPlacemark(for: location){ placemark in
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
    
    func setupContent(){
        view.setRoundedBorders(radius: 10)
        locationLabel.textAlignment = .center
        contentView.addSubviewWithAnchors(locationLabel, top: contentView.topAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        
        let coordinateLabel = UILabel(text: coordinate.asString)
        contentView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, insets: flatInsets)
            .centerX(contentView.centerXAnchor)
        
        let createLocationButton = UIButton().asTextButton("createLocation".localize()).withTextColor(color: .systemBlue).withRoundedCorners()
        createLocationButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.addLocation(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(createLocationButton, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let addImageButton = UIButton().asTextButton("addImage".localize()).withTextColor(color: .systemBlue).withRoundedCorners()
        addImageButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.openAddImage(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addImageButton, top: createLocationButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let addAudioButton = UIButton().asTextButton("addAudio".localize()).withTextColor(color: .systemBlue).withRoundedCorners()
        addAudioButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.openAudioRecorder(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addAudioButton, top: addImageButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let addNoteButton = UIButton().asTextButton("addNote".localize()).withTextColor(color: .systemBlue).withRoundedCorners()
        addNoteButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
            self.delegate?.openAddNote(at: self.coordinate)
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(addNoteButton, top: addAudioButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        
    }
    
}
