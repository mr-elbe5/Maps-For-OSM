/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation
import AVFoundation

class PlaceViewController: PopupTableViewController{
    
    let editModeButton = UIButton().asIconButton("pencil.circle", color: .label)
    let addImageButton = UIButton().asIconButton("photo", color: .label)
    let addAudioButton = UIButton().asIconButton("mic", color: .label)
    let addNoteButton = UIButton().asIconButton("pencil.and.list.clipboard", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .red)
    
    var place: Place
    
    var delegate: TrackDelegate? = nil
    
    init(location: Place){
        self.place = location
        super.init()
        self.subheaderView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "place".localize()
        createSubheaderView()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AudioItemCell.self, forCellReuseIdentifier: AudioItemCell.CELL_IDENT)
        tableView.register(VideoItemCell.self, forCellReuseIdentifier: VideoItemCell.CELL_IDENT)
        tableView.register(ImageItemCell.self, forCellReuseIdentifier: ImageItemCell.CELL_IDENT)
        tableView.register(TrackItemCell.self, forCellReuseIdentifier: TrackItemCell.CELL_IDENT)
        tableView.register(NoteItemCell.self, forCellReuseIdentifier: NoteItemCell.CELL_IDENT)
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        headerView.addSubviewWithAnchors(editModeButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        editModeButton.addAction(UIAction(){ action in
            self.toggleEditMode()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(addImageButton, top: headerView.topAnchor, leading: editModeButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        addImageButton.addAction(UIAction(){ action in
            self.openAddImage()
        }, for: .touchDown)
        addImageButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(addAudioButton, top: headerView.topAnchor, leading: addImageButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        addAudioButton.addAction(UIAction(){ action in
            self.openAudioRecorder()
        }, for: .touchDown)
        addAudioButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(addNoteButton, top: headerView.topAnchor, leading: addAudioButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        addNoteButton.addAction(UIAction(){ action in
            self.openAddNote()
        }, for: .touchDown)
        addNoteButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(selectAllButton, top: headerView.topAnchor, leading: addNoteButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        selectAllButton.addAction(UIAction(){ action in
            self.toggleSelectAll()
        }, for: .touchDown)
        selectAllButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
        deleteButton.isHidden = !tableView.isEditing
        
        let infoButton = UIButton().asIconButton("info.circle")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = PlaceInfoViewController()
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    override func setupSubheaderView(subheaderView: UIView){
        let locationLabel = UILabel(text: place.address)
        locationLabel.textAlignment = .center
        subheaderView.addSubviewWithAnchors(locationLabel, top: subheaderView.topAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: place.coordinate.asString)
        coordinateLabel.textAlignment = .center
        subheaderView.addSubviewWithAnchors(coordinateLabel, top: locationLabel.bottomAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, bottom: subheaderView.bottomAnchor, insets: defaultInsets)
    }
    
    func openAddImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func openAudioRecorder(){
        AVCaptureDevice.askAudioAuthorization(){ result in
            switch result{
            case .success(()):
                DispatchQueue.main.async {
                    let audioCaptureController = AudioRecorderViewController()
                    audioCaptureController.modalPresentationStyle = .fullScreen
                    audioCaptureController.delegate = self
                    self.present(audioCaptureController, animated: true)
                }
                return
            case .failure:
                DispatchQueue.main.async {
                    self.showError("MainViewController audioNotAuthorized")
                }
                return
            }
        }
    }
    
    func openAddNote(){
        let controller = NoteViewController(coordinate: place.coordinate)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func toggleEditMode(){
        if tableView.isEditing{
            PlacePool.save()
            delegate?.placeChanged(place: place)
            editModeButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            tableView.isEditing = false
            addImageButton.isHidden = true
            addAudioButton.isHidden = true
            addNoteButton.isHidden = true
            selectAllButton.isHidden = true
            deleteButton.isHidden = true
        }
        else{
            editModeButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            tableView.isEditing = true
            addImageButton.isHidden = false
            addAudioButton.isHidden = false
            addNoteButton.isHidden = false
            selectAllButton.isHidden = false
            deleteButton.isHidden = false
        }
        place.deselectAllItems()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if tableView.isEditing{
            if place.allItemsSelected{
                place.deselectAllItems()
            }
            else{
                place.selectAllItems()
            }
            for cell in tableView.visibleCells{
                (cell as? PlaceItemCell)?.updateIconView(isEditing: true)
            }
        }
    }
    
    func deleteSelected(){
        var list = PlaceItemList()
        for i in 0..<place.itemCount{
            let item = place.item(at: i)
            if item.selected{
                list.append(item)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "confirmDeleteItems".localize(i: list.count), text: "deleteHint".localize()){
            print("deleting \(list.count) items")
            for item in list{
                self.place.deleteItem(item: item)
            }
            self.delegate?.placeChanged(place: self.place)
            self.tableView.reloadData()
        }
    }
    
}

extension PlaceViewController: NoteViewDelegate, AudioCaptureDelegate{
    
    func addNote(note: String, coordinate: CLLocationCoordinate2D) {
        if !note.isEmpty{
            let place = PlacePool.assertPlace(coordinate: coordinate)
            let item = NoteItem()
            item.text = note
            place.addItem(item: item)
            PlacePool.save()
            tableView.reloadData()
        }
    }
    
    func audioCaptured(item: AudioItem){
        if let coordinate = LocationService.shared.location?.coordinate{
            let location = PlacePool.assertPlace(coordinate: coordinate)
            location.addItem(item: item)
            PlacePool.save()
            tableView.reloadData()
            DispatchQueue.main.async {
                self.delegate?.placeChanged(place: item.place)
            }
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
        place.itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = place.item(at: indexPath.row)
        switch item.type{
        case .audio: 
            if let cell = tableView.dequeueReusableCell(withIdentifier: AudioItemCell.CELL_IDENT, for: indexPath) as? AudioItemCell, let audioItem = item as? AudioItem{
                cell.audioItem = audioItem
                cell.delegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                Log.error("no valid item/cell for audio")
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
                Log.error("no valid item/cell for video")
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
                Log.error("no valid item/cell for image")
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
                Log.error("no valid item/cell for track")
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
                Log.error("no valid item/cell for note")
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

extension PlaceViewController : PlaceDelegate{
    
    func placeChanged(place: Place) {
        self.delegate?.placeChanged(place: place)
    }
    
    func placesChanged() {
        self.delegate?.placesChanged()
    }
    
    func showPlaceOnMap(place: Place) {
        self.dismiss(animated: true)
        delegate?.showPlaceOnMap(place: place)
    }
    
}

extension PlaceViewController : VideoItemCellDelegate{
    
    func viewVideoItem(item: VideoItem) {
        let controller = VideoViewController()
        controller.videoURL = item.fileURL
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

extension PlaceViewController : ImageDelegate{
    
    func viewImageItem(item: ImageItem) {
        let controller = ImageViewController()
        controller.uiImage = item.getImage()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

extension PlaceViewController : TrackDelegate{
    
    func viewTrackItem(item: TrackItem) {
        let controller = TrackViewController(track: item)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func showTrackItemOnMap(item: TrackItem) {
        self.dismiss(animated: true){
            self.delegate?.showTrackItemOnMap(item: item)
        }
    }
    
}




