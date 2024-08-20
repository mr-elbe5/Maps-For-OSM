/*
Maps For OSM
App for display and use of OSM maps without MapKit
Copyright: Michael Rönnau mr@elbe5.de
*/

import AppKit
import CoreLocation



class LocationDetailView: MapDetailView {
    
    var location: Location
    
    var addImageButton: NSButton!
    var addVideoButton: NSButton!
    var addAudioButton: NSButton!
    var addNoteButton: NSButton!
    var selectAllButton: NSButton!
    var deleteSelectedButton: NSButton!
    var deleteLocationButton: NSButton!
    
    override var centerCoordinate: CLLocationCoordinate2D?{
        location.coordinate
    }
    
    init(location: Location){
        self.location = location
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        location.items.deselectAll()
    }
    
    override open func setupView(){
        createFixedView()
        super.setupView()
    }
    
    override func setupMenuView(){
        addImageButton = NSButton(icon: "photo", target: self, action: #selector(addImage))
        addImageButton.toolTip = "addImage".localize()
        menuView.addSubviewWithAnchors(addImageButton, top: menuView.topAnchor, leading: menuView.leadingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        addVideoButton = NSButton(icon: "video", target: self, action: #selector(addVideo))
        addVideoButton.toolTip = "addVideo".localize()
        menuView.addSubviewWithAnchors(addVideoButton, top: menuView.topAnchor, leading: addImageButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        addAudioButton = NSButton(icon: "mic", target: self, action: #selector(addAudio))
        addAudioButton.toolTip = "addAudio".localize()
        menuView.addSubviewWithAnchors(addAudioButton, top: menuView.topAnchor, leading: addVideoButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        addNoteButton = NSButton(icon: "pencil.and.list.clipboard", target: self, action: #selector(addNote))
        addNoteButton.toolTip = "addNote".localize()
        menuView.addSubviewWithAnchors(addNoteButton, top: menuView.topAnchor, leading: addAudioButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        selectAllButton = NSButton(icon: "checkmark.square", target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        menuView.addSubviewWithAnchors(selectAllButton, top: menuView.topAnchor, leading: addNoteButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        deleteSelectedButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteSelectedButton.toolTip = "deleteSelected".localize()
        menuView.addSubviewWithAnchors(deleteSelectedButton, top: menuView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        deleteLocationButton = NSButton(icon: "trash", color: .systemRed, target: self, action: #selector(deleteTrackpoint))
        deleteLocationButton.toolTip = "deleteLocation".localize()
        menuView.addSubviewWithAnchors(deleteLocationButton, top: menuView.topAnchor, leading: deleteSelectedButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        super.setupMenuView()
    }
    
    override func setupFixedView(){
        if let fixedView = fixedView{
            let header = NSTextField(labelWithString: "location".localize()).asHeadline()
            fixedView.addSubviewWithAnchors(header, top: fixedView.topAnchor, insets: defaultInsets)
                .centerX(fixedView.centerXAnchor)
            let addressLabel = NSTextField(labelWithString: location.address)
            fixedView.addSubviewWithAnchors(addressLabel, top: header.bottomAnchor, insets: defaultInsets)
                .centerX(fixedView.centerXAnchor)
            let coordinateLabel = NSTextField(labelWithString: location.coordinate.asString)
            fixedView.addSubviewWithAnchors(coordinateLabel, top: addressLabel.bottomAnchor, bottom: fixedView.bottomAnchor, insets: defaultInsets)
                .centerX(fixedView.centerXAnchor)
        }
    }
    
    override func setupContentView(){
        contentView.removeAllSubviews()
        var lastView: NSView? = nil
        for item in location.items{
            var itemView: LocationItemCellView
            switch item.type{
            case .image:
                let view = ImageCellView(image: item as! Image)
                view.delegate = self
                itemView = view
            case .audio:
                let view = AudioCellView(audio: item as! Audio)
                view.delegate = self
                itemView = view
            case .video:
                let view = VideoCellView(video: item as! Video)
                view.delegate = self
                itemView = view
            case .note:
                let view = NoteCellView(note: item as! Note)
                view.delegate = self
                itemView = view
            case .track:
                let view = TrackCellView(track: item as! Track)
                view.delegate = self
                itemView = view
            }
            contentView.addSubviewWithAnchors(itemView, top: lastView?.bottomAnchor ?? contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            lastView = itemView
            itemView.setupView()
        }
        lastView?.bottom(contentView.bottomAnchor, inset: defaultInset)
    }
    
    @objc func addImage(){
        MainViewController.instance.addImage(to: location)
        setupContentView()
    }
    
    @objc func addVideo(){
        MainViewController.instance.addVideo(to: location)
        setupContentView()
    }
    
    @objc func addAudio(){
        MainViewController.instance.addAudio(to: location)
        setupContentView()
    }
    
    @objc func addNote(){
        MainViewController.instance.addNote(to: location)
        setupContentView()
    }
    
    @objc func toggleSelectAll(){
        if location.allItemsSelected{
            location.deselectAllItems()
        }
        else{
            location.selectAllItems()
        }
    }
    
    @objc func deleteSelected(){
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
        if NSAlert.acceptWarning(title: "confirmDeleteItems".localize(i: list.count), message: "deleteHint".localize()){
            print("deleting \(list.count) items")
            for item in list{
                self.location.deleteItem(item: item)
            }
            MainViewController.instance.locationsChanged()
            self.setupContentView()
        }
    }
    
    @objc func deleteTrackpoint(){
        if NSAlert.acceptWarning(title: "confirmDeleteLocation".localize(), message: "deleteHint".localize()){
            print("deleting location")
            AppData.shared.deleteLocation(self.location)
            MainViewController.instance.locationsChanged()
        }
    }
    
}

extension LocationDetailView: LocationItemDelegate{
    
    func itemsChanged() {
        setupContentView()
    }
    
}

extension LocationDetailView: ImageCellDelegate{
    
    func editImage(_ image: Image) {
        let controller = EditImageViewController(image: image)
        if ModalWindow.run(title: "editImage".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            AppData.shared.save()
            setupContentView()
        }
    }
    
}

extension LocationDetailView: NoteCellDelegate{
    
    func editNote(_ note: Note) {
        let controller = EditNoteViewController(note: note)
        if ModalWindow.run(title: "editNote".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            AppData.shared.save()
            setupContentView()
        }
    }
    
}

extension LocationDetailView: AudioCellDelegate{
    
    func editAudio(_ audio: Audio) {
        let controller = EditAudioViewController(audio: audio)
        if ModalWindow.run(title: "editAudio".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            AppData.shared.save()
            setupContentView()
        }
    }
    
}

extension LocationDetailView: TrackCellDelegate{
    
    func editTrack(_ track: Track) {
        if track.trackpoints.count > 100{
            NSAlert.showMessage(message: "manyTrackpoints".localize(i: track.trackpoints.count))
        }
        let controller = EditTrackViewController(track: track)
        if ModalWindow.run(title: "editTrack".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            AppData.shared.save()
            setupContentView()
        }
    }
    
}

extension LocationDetailView: VideoCellDelegate{
    
    func editVideo(_ video: Video) {
        let controller = EditVideoViewController(video: video)
        if ModalWindow.run(title: "editVideo".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 800, height: 600)) == .OK{
            AppData.shared.save()
            setupContentView()
        }
    }
    
}

