/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol LocationViewDelegate{
    func updateLocationLayer()
    func showTrackOnMap(track: TrackData)
}

class PlaceDetailViewController: PopupScrollViewController{
    
    let editButton = IconButton(icon: "pencil.circle", tintColor: .white)
    let deleteButton = IconButton(icon: "trash", tintColor: .white)
    
    let descriptionContainerView = UIView()
    var descriptionView : TextEditArea? = nil
    let photoStackView = UIStackView()
    let trackStackView = UIStackView()
    
    var editMode = false
    
    var location: Place? = nil
    var hadPhotos = false
    
    var delegate: LocationViewDelegate? = nil
    
    override func loadView() {
        title = "location".localize()
        super.loadView()
        scrollView.setupVertical()
        setupContent()
        setupKeyboard()
    }
    
    override func setupHeaderView(){
        super.setupHeaderView()
        
        let addPhotoButton = IconButton(icon: "photo", tintColor: .white)
        headerView.addSubview(addPhotoButton)
        addPhotoButton.addTarget(self, action: #selector(addPhoto), for: .touchDown)
        addPhotoButton.setAnchors(top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        
        headerView.addSubview(editButton)
        editButton.addTarget(self, action: #selector(toggleEditMode), for: .touchDown)
        editButton.setAnchors(top: headerView.topAnchor, leading: addPhotoButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        
        headerView.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(deleteLocation), for: .touchDown)
        deleteButton.setAnchors(top: headerView.topAnchor, leading: editButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
    }
    
    func setupContent(){
        if let location = location{
            hadPhotos = location.hasPhotos
            var header = UILabel(header: "locationData".localize())
            contentView.addSubview(header)
            header.setAnchors(top: contentView.topAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
            let locationLabel = UILabel(text: location.locationString)
            contentView.addSubview(locationLabel)
            locationLabel.setAnchors(top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            let coordinateLabel = UILabel(text: location.coordinateString)
            contentView.addSubview(coordinateLabel)
            coordinateLabel.setAnchors(top: locationLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
            header = UILabel(header: "description".localize())
            contentView.addSubview(header)
            header.setAnchors(top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
            contentView.addSubview(descriptionContainerView)
            descriptionContainerView.setAnchors(top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
            setupDescriptionContainerView()
            header = UILabel(header: "photos".localize())
            contentView.addSubview(header)
            header.setAnchors(top: descriptionContainerView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            photoStackView.setupVertical()
            setupPhotoStackView()
            contentView.addSubview(photoStackView)
            photoStackView.setAnchors(top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: 0, right: defaultInset))
            header = UILabel(header: "tracks".localize())
            contentView.addSubview(header)
            header.setAnchors(top: photoStackView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            trackStackView.setupVertical()
            setupTrackStackView()
            contentView.addSubview(trackStackView)
            trackStackView.setAnchors(top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: 0, bottom: 0, right: 0))
        }
    }
    
    func setupDescriptionContainerView(){
        descriptionContainerView.removeAllSubviews()
        guard let location = location else {return}
        if editMode{
            descriptionView = TextEditArea()
            descriptionView!.text = location.description
            descriptionView?.setGrayRoundedBorders()
            descriptionView?.setDefaults()
            descriptionView?.isScrollEnabled = false
            descriptionView?.setKeyboardToolbar(doneTitle: "done".localize())
            descriptionContainerView.addSubview(descriptionView!)
            descriptionView!.setAnchors(top: descriptionContainerView.topAnchor, leading: descriptionContainerView.leadingAnchor, trailing: descriptionContainerView.trailingAnchor, insets: defaultInsets)
            let saveButton = UIButton()
            saveButton.setTitle("save".localize(), for: .normal)
            saveButton.setTitleColor(.systemBlue, for: .normal)
            saveButton.addTarget(self, action: #selector(save), for: .touchDown)
            descriptionContainerView.addSubview(saveButton)
            saveButton.setAnchors(top: descriptionView!.bottomAnchor, bottom: descriptionContainerView.bottomAnchor, insets: defaultInsets)
                .centerX(descriptionContainerView.centerXAnchor)
        }
        else{
            descriptionView = nil
            let descriptionLabel = UILabel(text: location.description)
            descriptionContainerView.addSubview(descriptionLabel)
            descriptionLabel.setAnchors(top: descriptionContainerView.topAnchor, leading: descriptionContainerView.leadingAnchor, trailing: descriptionContainerView.trailingAnchor, bottom: descriptionContainerView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    func setupPhotoStackView(){
        photoStackView.removeAllArrangedSubviews()
        photoStackView.removeAllSubviews()
        guard let location = location else {return}
        for photo in location.photos{
            let photoView = PhotoListItemView(data: photo)
            photoView.delegate = self
            photoStackView.addArrangedSubview(photoView)
        }
    }
    
    func setupTrackStackView(){
        trackStackView.removeAllArrangedSubviews()
        trackStackView.removeAllSubviews()
        guard let location = location else {return}
        for track in location.tracks{
            let trackView = TrackListItemView(data: track)
            trackView.delegate = self
            trackStackView.addArrangedSubview(trackView)
        }
    }
    
    @objc func addPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @objc func toggleEditMode(){
        if editMode{
            editButton.tintColor = .white
            editMode = false
        }
        else{
            editButton.tintColor = .systemBlue
            editMode = true
        }
        setupDescriptionContainerView()
        setupPhotoStackView()
    }
    
    @objc func deleteLocation(){
        if let loc = location{
            showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationHint".localize()){
                Places.deleteLocation(loc)
                self.dismiss(animated: true){
                    self.delegate?.updateLocationLayer()
                }
            }
        }
    }
    
    @objc func save(){
        var needsUpdate = false
        if let location = location{
            location.description = descriptionView?.text ?? ""
            Places.save()
            needsUpdate = location.hasPhotos != hadPhotos
        }
        self.dismiss(animated: true){
            if needsUpdate{
                self.delegate?.updateLocationLayer()
            }
        }
    }
    
}

extension PlaceDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL else {return}
        let photo = PhotoData()
        if FileController.copyFile(fromURL: imageURL, toURL: photo.fileURL){
            location?.addPhoto(photo: photo)
            Places.save()
            delegate?.updateLocationLayer()
            let photoView = PhotoListItemView(data: photo)
            photoView.delegate = self
            photoStackView.addArrangedSubview(photoView)
        }
        picker.dismiss(animated: false)
    }
    
}

extension PlaceDetailViewController: PhotoListItemDelegate{
    
    func viewPhoto(sender: PhotoListItemView) {
        let photoViewController = PhotoViewController()
        photoViewController.uiImage = sender.photoData.getImage()
        photoViewController.modalPresentationStyle = .fullScreen
        self.present(photoViewController, animated: true)
    }
    
    func sharePhoto(sender: PhotoListItemView) {
        let alertController = UIAlertController(title: title, message: "shareImage".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            FileController.copyImageToLibrary(name: sender.photoData.fileName, fromDir: FileController.privateURL){ result in
                DispatchQueue.main.async {
                    switch result{
                    case .success:
                        self.showAlert(title: "success".localize(), text: "photoShared".localize())
                    case .failure(let err):
                        self.showAlert(title: "error".localize(), text: err.errorDescription!)
                    }
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func deletePhoto(sender: PhotoListItemView) {
        showDestructiveApprove(title: "confirmDeletePhoto".localize(), text: "deletePhotoHint".localize()){
            if let location = self.location{
                location.deletePhoto(photo: sender.photoData)
                Places.save()
                self.delegate?.updateLocationLayer()
                for subView in self.photoStackView.subviews{
                    if subView == sender{
                        self.photoStackView.removeArrangedSubview(subView)
                        self.photoStackView.removeSubview(subView)
                        break
                    }
                }
            }
        }
    }
    
}

extension PlaceDetailViewController: TrackListItemDelegate{
    
    func viewTrack(sender: TrackListItemView) {
        let trackController = TrackDetailViewController()
        trackController.track = sender.trackData
        trackController.delegate = self
        trackController.modalPresentationStyle = .fullScreen
        self.present(trackController, animated: true)
    }
    
    func showTrackOnMap(sender: TrackListItemView) {
        self.dismiss(animated: true){
            self.delegate?.showTrackOnMap(track: sender.trackData)
        }
    }
    
    func exportTrack    (sender: TrackListItemView) {
        if let url = GPXCreator.createTemporaryFile(track: sender.trackData){
            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
            present(controller, animated: true) {
                FileController.logFileInfo()
            }
        }
    }
    
    func deleteTrack(sender: TrackListItemView) {
        showDestructiveApprove(title: "confirmDeleteTrack".localize(), text: "deleteTrackHint".localize()){
            if let location = self.location{
                location.deleteTrack(track: sender.trackData)
                Places.save()
                self.delegate?.updateLocationLayer()
                for subView in self.trackStackView.subviews{
                    if subView == sender{
                        self.trackStackView.removeArrangedSubview(subView)
                        self.trackStackView.removeSubview(subView)
                        break
                    }
                }
            }
        }
    }
    
}

extension PlaceDetailViewController: TrackDetailDelegate{
    
    func showTrackOnMap(track: TrackData) {
        delegate?.showTrackOnMap(track: track)
    }
    
}
