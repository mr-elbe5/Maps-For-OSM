/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation
import E5Data
import E5IOSUI
import E5MapData
import Maps_For_OSM_Data

class PlaceViewController: PopupTableViewController{
    
    let editModeButton = UIButton().asIconButton("pencil.circle", color: .label)
    let addImageButton = UIButton().asIconButton("photo", color: .label)
    let addAudioButton = UIButton().asIconButton("mic", color: .label)
    let addNoteButton = UIButton().asIconButton("pencil.and.list.clipboard", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteSelectedButton = UIButton().asIconButton("trash.square", color: .red)
    let deletePlaceButton = UIButton().asIconButton("trash", color: .red)
    
    var place: Place
    
    var placeDelegate: PlaceDelegate? = nil
    var trackDelegate: TrackDelegate? = nil
    
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
        tableView.register(AudioCell.self, forCellReuseIdentifier: AudioCell.CELL_IDENT)
        tableView.register(VideoCell.self, forCellReuseIdentifier: VideoCell.CELL_IDENT)
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.CELL_IDENT)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.CELL_IDENT)
        tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.CELL_IDENT)
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
        
        headerView.addSubviewWithAnchors(deleteSelectedButton, top: headerView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteSelectedButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
        deleteSelectedButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(deletePlaceButton, top: headerView.topAnchor, leading: deleteSelectedButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deletePlaceButton.addAction(UIAction(){ action in
            self.deletePlace()
        }, for: .touchDown)
        deletePlaceButton.isHidden = !tableView.isEditing
        
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = PlaceInfoViewController()
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
            AppData.shared.saveLocally()
            placeDelegate?.placeChanged(place: place)
            editModeButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            tableView.isEditing = false
            addImageButton.isHidden = true
            addAudioButton.isHidden = true
            addNoteButton.isHidden = true
            selectAllButton.isHidden = true
            deleteSelectedButton.isHidden = true
            deletePlaceButton.isHidden = true
        }
        else{
            editModeButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            tableView.isEditing = true
            addImageButton.isHidden = false
            addAudioButton.isHidden = false
            addNoteButton.isHidden = false
            selectAllButton.isHidden = false
            deleteSelectedButton.isHidden = false
            deletePlaceButton.isHidden = false
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
            self.placeDelegate?.placeChanged(place: self.place)
            self.tableView.reloadData()
        }
    }
    
    func deletePlace(){
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deleteHint".localize()){
            print("deleting place")
            AppData.shared.deletePlace(self.place)
            self.placeDelegate?.placesChanged()
            self.dismiss(animated: false)
        }
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: AudioCell.CELL_IDENT, for: indexPath) as? AudioCell, let audioItem = item as? AudioItem{
                cell.audio = audioItem
                cell.placeDelegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                Log.error("no valid item/cell for audio")
                return UITableViewCell()
            }
        case .video:
            if let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.CELL_IDENT, for: indexPath) as? VideoCell, let videoItem = item as? VideoItem{
                cell.video = videoItem
                cell.placeDelegate = self
                cell.videoDelegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                Log.error("no valid item/cell for video")
                return UITableViewCell()
            }
        case .image:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.CELL_IDENT, for: indexPath) as? ImageCell, let imageItem = item as? ImageItem{
                cell.image = imageItem
                cell.placeDelegate = self
                cell.imageDelegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                Log.error("no valid item/cell for image")
                return UITableViewCell()
            }
        case .track:
            if let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.CELL_IDENT, for: indexPath) as? TrackCell, let trackItem = item as? TrackItem{
                cell.track = trackItem
                cell.placeDelegate = self
                cell.trackDelegate = self
                cell.updateCell(isEditing: tableView.isEditing)
                return cell
            }
            else{
                Log.error("no valid item/cell for track")
                return UITableViewCell()
            }
        case .note:
            if let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.CELL_IDENT, for: indexPath) as? NoteCell, let noteItem = item as? NoteItem{
                cell.note = noteItem
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
        self.placeDelegate?.placeChanged(place: place)
    }
    
    func placesChanged() {
        self.placeDelegate?.placesChanged()
    }
    
    func showPlaceOnMap(place: Place) {
        self.dismiss(animated: true)
        placeDelegate?.showPlaceOnMap(place: place)
    }
    
}

extension PlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL else {return}
        let image = ImageItem()
        //image.setFileNameFromURL(imageURL)
        if FileManager.default.copyFile(fromURL: imageURL, toURL: image.fileURL){
            place.addItem(item: image)
            AppData.shared.saveLocally()
            self.tableView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
}

extension PlaceViewController: NoteViewDelegate{
    
    func addNote(text: String, coordinate: CLLocationCoordinate2D) {
        if !text.isEmpty{
            let item = NoteItem()
            item.text = text
            var newPlace = false
            var place = AppData.shared.getPlace(coordinate: coordinate)
            if place == nil{
                place = AppData.shared.createPlace(coordinate: coordinate)
                newPlace = true
            }
            place!.addItem(item: item)
            AppData.shared.saveLocally()
            tableView.reloadData()
            DispatchQueue.main.async {
                if newPlace{
                    self.placesChanged()
                }
                else{
                    self.placeChanged(place: place!)
                }
            }
        }
    }
    
}

extension PlaceViewController: AudioCaptureDelegate{
    
    func audioCaptured(audio: AudioItem){
        if let coordinate = LocationService.shared.location?.coordinate{
            var newPlace = false
            var place = AppData.shared.getPlace(coordinate: coordinate)
            if place == nil{
                place = AppData.shared.createPlace(coordinate: coordinate)
                newPlace = true
            }
            place!.addItem(item: audio)
            AppData.shared.saveLocally()
            tableView.reloadData()
            DispatchQueue.main.async {
                if newPlace{
                    self.placesChanged()
                }
                else{
                    self.placeChanged(place: place!)
                }
            }
        }
    }
}

extension PlaceViewController : VideoDelegate{
    
    func viewVideoItem(item: VideoItem) {
        let controller = VideoViewController()
        controller.videoURL = item.fileURL
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

extension PlaceViewController : ImageDelegate{
    
    func viewImage(image: ImageItem) {
        let controller = ImageViewController()
        controller.uiImage = image.getImage()
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
            self.trackDelegate?.showTrackItemOnMap(item: item)
        }
    }
    
}




