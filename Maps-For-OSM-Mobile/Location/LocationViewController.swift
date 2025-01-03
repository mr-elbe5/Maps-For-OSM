/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation

class LocationViewController: NavTableViewController{
    
    let addImageButton = UIButton().asIconButton("photo", color: .label)
    let addAudioButton = UIButton().asIconButton("mic", color: .label)
    let addNoteButton = UIButton().asIconButton("pencil.and.list.clipboard", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteSelectedButton = UIButton().asIconButton("trash.square", color: .red)
    let deleteLocationButton = UIButton().asIconButton("trash", color: .red)
    
    var location: Location
    
    var locationDelegate : LocationDelegate? = nil
    var trackDelegate : TrackDelegate? = nil
    
    init(location: Location){
        self.location = location
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        createSubheaderView()
        super.loadView()
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationAudioCell.self, forCellReuseIdentifier: LocationAudioCell.LOCATION_CELL_IDENT)
        tableView.register(LocationVideoCell.self, forCellReuseIdentifier: LocationVideoCell.LOCATION_CELL_IDENT)
        tableView.register(LocationImageCell.self, forCellReuseIdentifier: LocationImageCell.LOCATION_CELL_IDENT)
        tableView.register(LocationTrackCell.self, forCellReuseIdentifier: LocationTrackCell.LOCATION_CELL_IDENT)
        tableView.register(LocationNoteCell.self, forCellReuseIdentifier: LocationNoteCell.LOCATION_CELL_IDENT)
    }
    
    override func updateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            AppData.shared.locations.deselectAll()
            self.close()
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "showOnMap".localize(), image: UIImage(systemName: "map"), primaryAction: UIAction(){ action in
            self.showLocationOnMap(coordinate: self.location.coordinate)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "addImage".localize(), image: UIImage(systemName: "photo"), primaryAction: UIAction(){ action in
            self.openAddImage()
        }))
        items.append(UIBarButtonItem(title: "addAudio".localize(), image: UIImage(systemName: "mic"), primaryAction: UIAction(){ action in
            self.openAudioRecorder()
        }))
        items.append(UIBarButtonItem(title: "addNote".localize(), image: UIImage(systemName: "square.and.pencil"), primaryAction: UIAction(){ action in
            self.openAddNote()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "deleteSelected".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteLocation()
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil")), items: items))
        navigationItem.trailingItemGroups = groups
        
    }
    
    override func setupSubheaderView(subheaderView: UIView){
        super.setupSubheaderView(subheaderView: subheaderView)
        let locationLabel = UILabel(text: location.address)
        locationLabel.textAlignment = .center
        subheaderView.addSubviewWithAnchors(locationLabel, top: subheaderView.topAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: location.coordinate.asString)
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
                    let controller = AudioRecorderViewController()
                    controller.delegate = self
                    self.navigationController?.pushViewController(controller, animated: true)
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
        let controller = NoteViewController(coordinate: location.coordinate)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func toggleSelectAll(){
        if location.allItemsSelected{
            location.deselectAllItems()
        }
        else{
            location.selectAllItems()
        }
        for cell in tableView.visibleCells{
            (cell as? LocationItemCell)?.updateIconView()
        }
    }
    
    func deleteSelected(){
        var list = LocatedItemsList()
        for i in 0..<location.itemCount{
            let item = location.item(at: i)
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
                self.location.deleteItem(item: item)
            }
            self.locationDelegate?.locationsChanged()
            self.tableView.reloadData()
        }
    }
    
    func deleteLocation(){
        showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteHint".localize()){
            print("deleting location")
            AppData.shared.deleteLocation(self.location)
            self.locationDelegate?.locationsChanged()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}

extension LocationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        location.itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = location.item(at: indexPath.row)
        switch item.type{
        case .audio: 
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationAudioCell.LOCATION_CELL_IDENT, for: indexPath) as? LocationAudioCell, let audio = item as? AudioItem{
                cell.audio = audio
                cell.delegate = self
                cell.updateCell()
                return cell
            }
            else{
                Log.error("no valid item/cell for audio")
                return UITableViewCell()
            }
        case .video:
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationVideoCell.LOCATION_CELL_IDENT, for: indexPath) as? LocationVideoCell, let video = item as? VideoItem{
                cell.video = video
                cell.delegate = self
                cell.updateCell()
                return cell
            }
            else{
                Log.error("no valid item/cell for video")
                return UITableViewCell()
            }
        case .image:
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationImageCell.LOCATION_CELL_IDENT, for: indexPath) as? LocationImageCell, let image = item as? ImageItem{
                cell.image = image
                cell.delegate = self
                cell.updateCell()
                return cell
            }
            else{
                Log.error("no valid item/cell for image")
                return UITableViewCell()
            }
        case .track:
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationTrackCell.LOCATION_CELL_IDENT, for: indexPath) as? LocationTrackCell, let track = item as? TrackItem{
                cell.track = track
                cell.trackDelegate = self
                cell.updateCell()
                return cell
            }
            else{
                Log.error("no valid item/cell for track")
                return UITableViewCell()
            }
        case .note:
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationNoteCell.LOCATION_CELL_IDENT, for: indexPath) as? LocationNoteCell, let note = item as? NoteItem{
                cell.note = note
                cell.delegate = self
                cell.updateCell()
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

extension LocationViewController : LocationItemCellDelegate{
    
    func locationChanged(location: Location) {
        tableView.reloadData()
        locationDelegate?.locationChanged(location: location)
    }
    
    func showLocationOnMap(coordinate: CLLocationCoordinate2D) {
        locationDelegate?.showLocationOnMap(coordinate: coordinate)
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension LocationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let imageURL = info[.imageURL] as? URL, let data = FileManager.default.readFile(url: imageURL){
            let image = ImageItem()
            var imageData = data
            let metaData = ImageMetaData()
            metaData.readData(data: data)
            if !metaData.hasGPSData{
                if let dataWithCoordinates = data.setImageProperties(altitude: location.altitude, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, utType: image.fileURL.utType!){
                    imageData = dataWithCoordinates
                }
            }
            if FileManager.default.saveFile(data: imageData, url: image.fileURL){
                location.addItem(item: image)
                AppData.shared.save()
                self.tableView.reloadData()
                picker.dismiss(animated: false)
                self.locationChanged(location: location)
                return
            }
        }
        picker.dismiss(animated: false)
        showError("imageImportError".localize())
    }
    
}

extension LocationViewController: NoteViewDelegate{
    
    func addNote(text: String, coordinate: CLLocationCoordinate2D) {
        if !text.isEmpty{
            let item = NoteItem()
            item.text = text
            location.addItem(item: item)
            AppData.shared.save()
            tableView.reloadData()
            self.locationDelegate?.locationChanged(location: location)
        }
    }
    
}

extension LocationViewController: AudioCaptureDelegate{
    
    func audioCaptured(audio: AudioItem){
        location.addItem(item: audio)
        AppData.shared.save()
        tableView.reloadData()
        self.locationDelegate?.locationChanged(location: location)
    }
}

extension LocationViewController : VideoCellDelegate{
    
    func viewVideo(item: VideoItem) {
        let controller = VideoViewController()
        controller.videoURL = item.fileURL
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension LocationViewController : ImageCellDelegate{
    
    func viewImage(image: ImageItem) {
        let controller = ImageViewController()
        controller.uiImage = image.getImage()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension LocationViewController : TrackDelegate{
    
    func trackChanged() {
        tableView.reloadData()
    }
    
    func editTrack(track: TrackItem) {
        let controller = TrackViewController(track: track)
        controller.trackDelegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showTrackOnMap(track: TrackItem) {
        navigationController?.popToRootViewController(animated: true)
        trackDelegate?.showTrackOnMap(track: track)
    }
    
}




