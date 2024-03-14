/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol PlaceViewDelegate{
    func updateMarkerLayer()
}

/*func getMarkerMenu(marker: PlaceMarker) -> UIMenu{
    var actions = Array<UIAction>()
    actions.append(UIAction(title: "addImage".localize()){ action in
        self.delegate?.addImageToPlace(place: marker.place)
    })
    actions.append(UIAction(title: "moveToScreenCenter".localize()){ action in
        self.delegate?.movePlaceToScreenCenter(place: marker.place)
    })
    return UIMenu(title: marker.place.name, children: actions)
}*/

class PlaceDetailViewController: PopupScrollViewController{
    
    let editButton = UIButton().asIconButton("pencil.circle", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .red)
    
    let noteContainerView = UIView()
    var noteEditView : TextEditArea? = nil
    let mediaStackView = UIStackView()
    
    var editMode = false
    
    var place: Place
    var hadPhotos = false
    
    var delegate: PlaceViewDelegate? = nil
    
    init(location: Place){
        self.place = location
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "place".localize()
        super.loadView()
        scrollView.setupVertical()
        setupContent()
        setupKeyboard()
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        let addImageButton = UIButton().asIconButton("photo", color: .label)
        headerView.addSubviewWithAnchors(addImageButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchDown)
        
        headerView.addSubviewWithAnchors(editButton, top: headerView.topAnchor, leading: addImageButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        editButton.addTarget(self, action: #selector(toggleEditMode), for: .touchDown)
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: editButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        deleteButton.addTarget(self, action: #selector(deletePlace), for: .touchDown)
    }
    
    func setupContent(){
        hadPhotos = place.hasMedia
        var header = UILabel(header: "placeData".localize())
        contentView.addSubviewWithAnchors(header, top: contentView.topAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        let locationLabel = UILabel(text: place.address)
        contentView.addSubviewWithAnchors(locationLabel, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: place.coordinate.asString)
        contentView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: flatInsets)
        
        header = UILabel(header: "note".localize())
        contentView.addSubviewWithAnchors(header, top: coordinateLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(noteContainerView, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
        setupNoteContainerView()
        
        header = UILabel(header: "media".localize())
        contentView.addSubviewWithAnchors(header, top: noteContainerView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        mediaStackView.setupVertical()
        setupMediaStackView()
        contentView.addSubviewWithAnchors(mediaStackView, top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: 0, right: defaultInset))
        
    }
    
    func setupNoteContainerView(){
        noteContainerView.removeAllSubviews()
        if editMode{
            let noteEditView = TextEditArea()
            noteEditView.text = place.note
            noteEditView.setGrayRoundedBorders()
            noteEditView.setDefaults()
            noteEditView.isScrollEnabled = false
            noteEditView.setKeyboardToolbar(doneTitle: "done".localize())
            noteContainerView.addSubviewWithAnchors(noteEditView, top: noteContainerView.topAnchor, leading: noteContainerView.leadingAnchor, trailing: noteContainerView.trailingAnchor, insets: defaultInsets)
            self.noteEditView = noteEditView
            
            let saveButton = UIButton()
            saveButton.setTitle("save".localize(), for: .normal)
            saveButton.setTitleColor(.systemBlue, for: .normal)
            saveButton.addTarget(self, action: #selector(save), for: .touchDown)
            noteContainerView.addSubviewWithAnchors(saveButton, top: noteEditView.bottomAnchor, bottom: noteContainerView.bottomAnchor, insets: defaultInsets)
                .centerX(noteContainerView.centerXAnchor)
        }
        else{
            self.noteEditView = nil
            let noteLabel = UILabel(text: place.note)
            noteContainerView.addSubviewWithAnchors(noteLabel, top: noteContainerView.topAnchor, leading: noteContainerView.leadingAnchor, trailing: noteContainerView.trailingAnchor, bottom: noteContainerView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    func setupMediaStackView(){
        mediaStackView.removeAllArrangedSubviews()
        mediaStackView.removeAllSubviews()
        for file in place.media{
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
        setupNoteContainerView()
    }
    
    @objc func deletePlace(){
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            PlacePool.deletePlace(self.place)
            self.dismiss(animated: true){
                self.delegate?.updateMarkerLayer()
            }
        }
    }
    
    @objc func save(){
        place.note = noteEditView?.text ?? ""
        PlacePool.save()
        if editMode{
            toggleEditMode()
        }
    }
    
}

extension PlaceDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL else {return}
        let image = ImageFile()
        //image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            place.addMedia(file: image)
            PlacePool.save()
            delegate?.updateMarkerLayer()
            let imageView = ImageListItemView(data: image)
            imageView.delegate = self
            mediaStackView.addArrangedSubview(imageView)
        }
        picker.dismiss(animated: false)
    }
    
}

extension PlaceDetailViewController: ImageListItemDelegate{
    
    func viewImage(sender: ImageListItemView) {
        let imageViewController = ImageViewController()
        imageViewController.uiImage = sender.imageData.getImage()
        imageViewController.modalPresentationStyle = .fullScreen
        self.present(imageViewController, animated: true)
    }
    
    func shareImage(sender: ImageListItemView) {
        let alertController = UIAlertController(title: title, message: "shareImage".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            FileController.copyImageToLibrary(name: sender.imageData.fileName, fromDir: FileController.mediaDirURL){ result in
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
            self.place.deleteMedia(file: sender.imageData)
            PlacePool.save()
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

extension PlaceDetailViewController: VideoListItemDelegate{
    
    func viewVideo(sender: VideoListItemView) {
        let videoViewController = VideoViewController()
        videoViewController.videoURL = sender.videoData.fileURL
        videoViewController.modalPresentationStyle = .fullScreen
        self.present(videoViewController, animated: true)
    }
    
    func deleteVideo(sender: VideoListItemView) {
        showDestructiveApprove(title: "confirmDeleteVideo".localize(), text: "deleteVideoHint".localize()){
            self.place.deleteMedia(file: sender.videoData)
            PlacePool.save()
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

extension PlaceDetailViewController: AudioListItemDelegate{
    
    func deleteAudio(sender: AudioListItemView) {
        showDestructiveApprove(title: "confirmDeleteAudio".localize(), text: "deleteAudioHint".localize()){
            self.place.deleteMedia(file: sender.audioData)
            PlacePool.save()
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

