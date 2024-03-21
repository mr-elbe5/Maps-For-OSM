/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol PlaceViewDelegate{
    func updateMarkerLayer()
    func showItemOnMap(place: Place, item: PlaceItem)
}

class PlaceViewController: PopupViewController{
    
    let editButton = UIButton().asIconButton("pencil.circle", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .red)
    
    let noteContainerView = UIView()
    var noteEditView : TextEditArea? = nil
    
    var tableView = UITableView()
    
    var editMode = false
    
    var place: Place
    var hadItems = false
    
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AudioItemCell.self, forCellReuseIdentifier: AudioItemCell.CELL_IDENT)
        tableView.register(VideoItemCell.self, forCellReuseIdentifier: VideoItemCell.CELL_IDENT)
        tableView.register(ImageItemCell.self, forCellReuseIdentifier: ImageItemCell.CELL_IDENT)
        tableView.register(TrackItemCell.self, forCellReuseIdentifier: TrackItemCell.CELL_IDENT)
        tableView.register(NoteItemCell.self, forCellReuseIdentifier: NoteItemCell.CELL_IDENT)
        
        let guide = view.safeAreaLayoutGuide
        
        let locationLabel = UILabel(text: place.address)
        locationLabel.textAlignment = .center
        view.addSubviewWithAnchors(locationLabel, top: headerView?.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: place.coordinate.asString)
        view.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, insets: flatInsets)
        
        view.addSubviewWithAnchors(tableView, top: coordinateLabel.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: defaultInsets)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        let addImageButton = UIButton().asIconButton("photo", color: .label)
        headerView.addSubviewWithAnchors(addImageButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        addImageButton.addAction(UIAction(){ action in
            self.addImage()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(editButton, top: headerView.topAnchor, leading: addImageButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        editButton.addAction(UIAction(){ action in
            self.toggleEditMode()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: editButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deletePlace()
        }, for: .touchDown)
    }
    
    func setupNoteContainerView(){
        noteContainerView.removeAllSubviews()
        if editMode{
            let noteEditView = TextEditArea().defaultWithBorder()
            noteEditView.text = place.note
            noteContainerView.addSubviewWithAnchors(noteEditView, top: noteContainerView.topAnchor, leading: noteContainerView.leadingAnchor, trailing: noteContainerView.trailingAnchor, insets: defaultInsets)
            self.noteEditView = noteEditView
            
            let saveButton = UIButton().asTextButton("save".localize(), color: .systemBlue)
            saveButton.addAction(UIAction(){ action in
                self.save()
            }, for: .touchDown)
            noteContainerView.addSubviewWithAnchors(saveButton, top: noteEditView.bottomAnchor, bottom: noteContainerView.bottomAnchor, insets: defaultInsets)
                .centerX(noteContainerView.centerXAnchor)
        }
        else{
            self.noteEditView = nil
            let noteLabel = UILabel(text: place.note)
            noteContainerView.addSubviewWithAnchors(noteLabel, top: noteContainerView.topAnchor, leading: noteContainerView.leadingAnchor, trailing: noteContainerView.trailingAnchor, bottom: noteContainerView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    func addImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func toggleEditMode(){
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
    
    func deletePlace(){
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            PlacePool.deletePlace(self.place)
            self.dismiss(animated: true){
                self.delegate?.updateMarkerLayer()
            }
        }
    }
    
    func save(){
        place.note = noteEditView?.text ?? ""
        PlacePool.save()
        if editMode{
            toggleEditMode()
        }
    }
    
}

extension PlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL else {return}
        let image = ImageItem()
        //image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            place.addItem(item: image)
            PlacePool.save()
            self.tableView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
}

extension PlaceViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        place.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = place.items[indexPath.row]
        switch item.type{
        case .audio: 
            if let cell = tableView.dequeueReusableCell(withIdentifier: AudioItemCell.CELL_IDENT, for: indexPath) as? AudioItemCell, let audioItem = item as? AudioItem{
                cell.audioItem = audioItem
                cell.delegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                print("no valid item/cell for audio")
                return UITableViewCell()
            }
        case .video:
            if let cell = tableView.dequeueReusableCell(withIdentifier: VideoItemCell.CELL_IDENT, for: indexPath) as? VideoItemCell, let videoItem = item as? VideoItem{
                cell.videoItem = videoItem
                cell.delegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                print("no valid item/cell for video")
                return UITableViewCell()
            }
        case .image:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ImageItemCell.CELL_IDENT, for: indexPath) as? ImageItemCell, let imageItem = item as? ImageItem{
                cell.imageItem = imageItem
                cell.delegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                print("no valid item/cell for image")
                return UITableViewCell()
            }
        case .track:
            if let cell = tableView.dequeueReusableCell(withIdentifier: TrackItemCell.CELL_IDENT, for: indexPath) as? TrackItemCell, let trackItem = item as? TrackItem{
                cell.trackItem = trackItem
                cell.delegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                print("no valid item/cell for track")
                return UITableViewCell()
            }
        case .note:
            if let cell = tableView.dequeueReusableCell(withIdentifier: NoteItemCell.CELL_IDENT, for: indexPath) as? NoteItemCell, let noteItem = item as? NoteItem{
                cell.noteItem = noteItem
                cell.delegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                print("no valid item/cell for note")
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension PlaceViewController : AudioItemCellDelegate{
    
    func deleteAudioItem(item: AudioItem) {
        showDestructiveApprove(title: "confirmDeleteAudioItem".localize(), text: "deleteItemHint".localize()){
            self.place.deleteItem(item: item)
            PlacePool.save()
            self.delegate?.updateMarkerLayer()
            self.tableView.reloadData()
        }
    }
    
}

extension PlaceViewController : VideoItemCellDelegate{
    
    func deleteVideoItem(item: VideoItem) {
        showDestructiveApprove(title: "confirmDeleteVideoItem".localize(), text: "deleteItemHint".localize()){
            self.place.deleteItem(item: item)
            PlacePool.save()
            self.delegate?.updateMarkerLayer()
            self.tableView.reloadData()
        }
    }
    
    func viewVideoItem(item: VideoItem) {
        let controller = VideoViewController()
        controller.videoURL = item.fileURL
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

extension PlaceViewController : ImageItemCellDelegate{
    
    func deleteImageItem(item: ImageItem) {
        showDestructiveApprove(title: "confirmDeleteImageItem".localize(), text: "deleteItemHint".localize()){
            self.place.deleteItem(item: item)
            PlacePool.save()
            self.delegate?.updateMarkerLayer()
            self.tableView.reloadData()
        }
    }
    
    func viewImageItem(item: ImageItem) {
        let controller = ImageViewController()
        controller.uiImage = item.getImage()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

extension PlaceViewController : TrackItemCellDelegate{
    
    func deleteTrackItem(item: TrackItem) {
        showDestructiveApprove(title: "confirmDeleteTrackItem".localize(), text: "deleteItemHint".localize()){
            self.place.deleteItem(item: item)
            PlacePool.save()
            self.delegate?.updateMarkerLayer()
            self.tableView.reloadData()
        }
    }
    
    func viewTrackItem(item: TrackItem) {
        let controller = TrackViewController(track: item)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func showItemOnMap(item: TrackItem) {
        self.dismiss(animated: true){
            self.delegate?.showItemOnMap(place: self.place, item: item)
        }
    }
    
}

extension PlaceViewController : NoteItemCellDelegate{
    
    func deleteNoteItem(item: NoteItem) {
        showDestructiveApprove(title: "confirmDeleteNoteItem".localize(), text: "deleteItemHint".localize()){
            self.place.deleteItem(item: item)
            PlacePool.save()
            self.delegate?.updateMarkerLayer()
            self.tableView.reloadData()
        }
    }
    
}



