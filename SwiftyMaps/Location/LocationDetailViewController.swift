/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol LocationViewDelegate{
    func updateMarkerLayer()
}

class LocationDetailViewController: PopupScrollViewController{
    
    let editButton = UIButton().asIconButton("pencil.circle", color: .white)
    let deleteButton = UIButton().asIconButton("trash", color: .white)
    
    let descriptionContainerView = UIView()
    var descriptionView : TextEditArea? = nil
    let mediaStackView = UIStackView()
    
    var editMode = false
    
    var location: Location
    var hadPhotos = false
    
    var delegate: LocationViewDelegate? = nil
    
    init(location: Location){
        self.location = location
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "location".localize()
        super.loadView()
        scrollView.setupVertical()
        setupContent()
        setupKeyboard()
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        let addImageButton = UIButton().asIconButton("photo", color: .white)
        headerView.addSubviewWithAnchors(addImageButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchDown)
        
        headerView.addSubviewWithAnchors(editButton, top: headerView.topAnchor, leading: addImageButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        editButton.addTarget(self, action: #selector(toggleEditMode), for: .touchDown)
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: editButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        deleteButton.addTarget(self, action: #selector(deleteLocation), for: .touchDown)
    }
    
    func setupContent(){
        hadPhotos = location.hasMedia
        var header = UILabel(header: "locationData".localize())
        contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        let locationLabel = UILabel(text: location.address)
        contentView.addSubviewWithAnchors(locationLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: location.coordinateString)
        contentView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        header = UILabel(header: "description".localize())
        contentView.addSubviewWithAnchors(header, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(descriptionContainerView, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
        setupDescriptionContainerView()
        
        header = UILabel(header: "media".localize())
        contentView.addSubviewWithAnchors(header, top: descriptionContainerView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        mediaStackView.setupVertical()
        setupMediaStackView()
        contentView.addSubviewWithAnchors(mediaStackView, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: 0, right: defaultInset))
        
        header = UILabel(header: "tracks".localize())
        contentView.addSubviewWithAnchors(header, top: mediaStackView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
    }
    
    func setupDescriptionContainerView(){
        descriptionContainerView.removeAllSubviews()
        if editMode{
            descriptionView = TextEditArea()
            descriptionView!.text = location.description
            descriptionView?.setGrayRoundedBorders()
            descriptionView?.setDefaults()
            descriptionView?.isScrollEnabled = false
            descriptionView?.setKeyboardToolbar(doneTitle: "done".localize())
            descriptionContainerView.addSubviewWithAnchors(descriptionView!, top: descriptionContainerView.topAnchor, leading: descriptionContainerView.leadingAnchor, trailing: descriptionContainerView.trailingAnchor, insets: defaultInsets)
            
            let saveButton = UIButton()
            saveButton.setTitle("save".localize(), for: .normal)
            saveButton.setTitleColor(.systemBlue, for: .normal)
            saveButton.addTarget(self, action: #selector(save), for: .touchDown)
            descriptionContainerView.addSubviewWithAnchors(saveButton, top: descriptionView!.bottomAnchor, bottom: descriptionContainerView.bottomAnchor, insets: defaultInsets)
                .centerX(descriptionContainerView.centerXAnchor)
        }
        else{
            descriptionView = nil
            let descriptionLabel = UILabel(text: location.description)
            descriptionContainerView.addSubviewWithAnchors(descriptionLabel, top: descriptionContainerView.topAnchor, leading: descriptionContainerView.leadingAnchor, trailing: descriptionContainerView.trailingAnchor, bottom: descriptionContainerView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    func setupMediaStackView(){
        mediaStackView.removeAllArrangedSubviews()
        mediaStackView.removeAllSubviews()
        for file in location.media{
            switch file.type{
            case .image:
                if let image = file.data as? ImageFile{
                    let imageView = ImageListItemView(data: image)
                    imageView.delegate = self
                    mediaStackView.addArrangedSubview(imageView)
                }
            case .video:
                if let video = file.data as? VideoFile{
                    let videoView = VideoListItemView(data: video)
                    videoView.delegate = self
                    mediaStackView.addArrangedSubview(videoView)
                }
            case .audio:
                if let audio = file.data as? AudioFile{
                    let audioView = AudioListItemView(data: audio)
                    audioView.delegate = self
                    mediaStackView.addArrangedSubview(audioView)
                }
            }
        }
    }
    
    @objc func addImage(){
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
        setupMediaStackView()
    }
    
    @objc func deleteLocation(){
        showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationHint".localize()){
            Locations.deleteLocation(self.location)
            self.dismiss(animated: true){
                self.delegate?.updateMarkerLayer()
            }
        }
    }
    
    @objc func save(){
        var needsUpdate = false
        location.note = descriptionView?.text ?? ""
        Locations.save()
        needsUpdate = location.hasMedia != hadPhotos
        self.dismiss(animated: true){
            if needsUpdate{
                self.delegate?.updateMarkerLayer()
            }
        }
    }
    
}

extension LocationDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL else {return}
        let image = ImageFile()
        //image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            location.addMedia(file: image)
            Locations.save()
            delegate?.updateMarkerLayer()
            let imageView = ImageListItemView(data: image)
            imageView.delegate = self
            mediaStackView.addArrangedSubview(imageView)
        }
        picker.dismiss(animated: false)
    }
    
}

extension LocationDetailViewController: ImageListItemDelegate{
    
    func viewImage(sender: ImageListItemView) {
        let imageViewController = ImageViewController()
        imageViewController.uiImage = sender.imageData.getImage()
        imageViewController.modalPresentationStyle = .fullScreen
        self.present(imageViewController, animated: true)
    }
    
    func shareImage(sender: ImageListItemView) {
        let alertController = UIAlertController(title: title, message: "shareImage".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            FileController.copyImageToLibrary(name: sender.imageData.fileName, fromDir: FileController.privateURL){ result in
                DispatchQueue.main.async {
                    switch result{
                    case .success:
                        self.showAlert(title: "success".localize(), text: "imageShared".localize())
                    case .failure(let err):
                        self.showAlert(title: "error".localize(), text: err.errorDescription!)
                    }
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func deleteImage(sender: ImageListItemView) {
        showDestructiveApprove(title: "confirmDeleteImage".localize(), text: "deleteImageHint".localize()){
            self.location.deleteMedia(file: sender.imageData)
            Locations.save()
            self.delegate?.updateMarkerLayer()
            for subView in self.mediaStackView.subviews{
                if subView == sender{
                    self.mediaStackView.removeArrangedSubview(subView)
                    self.mediaStackView.removeSubview(subView)
                    break
                }
            }
        }
    }
    
}

extension LocationDetailViewController: VideoListItemDelegate{
    
    func viewVideo(sender: VideoListItemView) {
        let videoViewController = VideoViewController()
        videoViewController.videoURL = sender.videoData.fileURL
        videoViewController.modalPresentationStyle = .fullScreen
        self.present(videoViewController, animated: true)
    }
    
    func shareVideo(sender: VideoListItemView) {
        let alertController = UIAlertController(title: title, message: "shareVideo".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            FileController.copyImageToLibrary(name: sender.videoData.fileName, fromDir: FileController.privateURL){ result in
                DispatchQueue.main.async {
                    switch result{
                    case .success:
                        self.showAlert(title: "success".localize(), text: "videoShared".localize())
                    case .failure(let err):
                        self.showAlert(title: "error".localize(), text: err.errorDescription!)
                    }
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func deleteVideo(sender: VideoListItemView) {
        showDestructiveApprove(title: "confirmDeleteVideo".localize(), text: "deleteVideoHint".localize()){
            self.location.deleteMedia(file: sender.videoData)
            Locations.save()
            self.delegate?.updateMarkerLayer()
            for subView in self.mediaStackView.subviews{
                if subView == sender{
                    self.mediaStackView.removeArrangedSubview(subView)
                    self.mediaStackView.removeSubview(subView)
                    break
                }
            }
        }
    }
    
    
}

extension LocationDetailViewController: AudioListItemDelegate{
    
    func shareAudio(sender: AudioListItemView) {
        let alertController = UIAlertController(title: title, message: "shareAudio".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            FileController.copyImageToLibrary(name: sender.audioData.fileName, fromDir: FileController.privateURL){ result in
                DispatchQueue.main.async {
                    switch result{
                    case .success:
                        self.showAlert(title: "success".localize(), text: "videoShared".localize())
                    case .failure(let err):
                        self.showAlert(title: "error".localize(), text: err.errorDescription!)
                    }
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func deleteAudio(sender: AudioListItemView) {
        showDestructiveApprove(title: "confirmDeleteAudio".localize(), text: "deleteAudioHint".localize()){
            self.location.deleteMedia(file: sender.audioData)
            Locations.save()
            self.delegate?.updateMarkerLayer()
            for subView in self.mediaStackView.subviews{
                if subView == sender{
                    self.mediaStackView.removeArrangedSubview(subView)
                    self.mediaStackView.removeSubview(subView)
                    break
                }
            }
        }
    }
    
    
}

