/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import PhotosUI
import E5Data
import E5IOSUI
import E5PhotoLib
import E5MapData

class ImageListViewController: PopupTableViewController{
    
    class Day{
        
        var date: Date
        var images = ImageList()
        
        init(_ date: Date){
            self.date = date
        }
        
    }

    let editModeButton = UIButton().asIconButton("pencil", color: .label)
    let sortButton = UIButton().asIconButton("arrow.up.arrow.down", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let exportSelectedButton = UIButton().asIconButton("square.and.arrow.up", color: .label)
    let deleteButton = UIButton().asIconButton("trash.square", color: .systemRed)
    
    var placeDelegate: PlaceDelegate? = nil
    var imageDelegate: ImageDelegate? = nil
    
    var images = ImageList()
    var days = Array<Day>()
    
    override open func loadView() {
        title = "images".localize()
        super.loadView()
        images = AppData.shared.places.imageItems
        setupData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.CELL_IDENT)
    }
    
    func setupData(){
        days.removeAll()
        images.sort()
        for image in images{
            let startOfDay = image.creationDate.startOfDay()
            if let day = days.first(where: { day in
                day.date == startOfDay
            }){
                day.images.append(image)
            }
            else{
                let day = Day(startOfDay)
                day.images.append(image)
                days.append(day)
            }
        }
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        headerView.addSubviewWithAnchors(sortButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        sortButton.addAction(UIAction(){ action in
            self.sortImages()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(editModeButton, top: headerView.topAnchor, leading: sortButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        editModeButton.addAction(UIAction(){ action in
            self.toggleEditMode()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(selectAllButton, top: headerView.topAnchor, leading: editModeButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        selectAllButton.addAction(UIAction(){ action in
            self.toggleSelectAll()
        }, for: .touchDown)
        selectAllButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(exportSelectedButton, top: headerView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        exportSelectedButton.addAction(UIAction(){ action in
            self.exportSelected()
        }, for: .touchDown)
        exportSelectedButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: exportSelectedButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
        deleteButton.isHidden = !tableView.isEditing
        
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = ImageListInfoViewController()
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    func toggleEditMode(){
        if tableView.isEditing{
            editModeButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            tableView.isEditing = false
            selectAllButton.isHidden = true
            exportSelectedButton.isHidden = true
            deleteButton.isHidden = true
        }
        else{
            editModeButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            tableView.isEditing = true
            selectAllButton.isHidden = false
            exportSelectedButton.isHidden = false
            deleteButton.isHidden = false
        }
        images.deselectAll()
        tableView.reloadData()
    }
    
    func sortImages(){
        AppState.shared.sortAscending = !AppState.shared.sortAscending
        AppData.shared.places.sortAll()
        setupData()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if tableView.isEditing{
            if images.allSelected{
                images.deselectAll()
            }
            else{
                images.selectAll()
            }
            for cell in tableView.visibleCells{
                (cell as? ImageCell)?.updateIconView(isEditing: true)
            }
        }
    }
    
    func exportSelected(){
        var exportList = Array<ImageItem>()
        for i in 0..<images.count{
            let image = images[i]
            if image.selected{
                exportList.append(image)
            }
        }
        if exportList.isEmpty{
            return
        }
        let spinner = startSpinner()
        DispatchQueue.global(qos: .userInitiated).async {
            PHPhotoLibrary.requestAuthorization(){ status in
                if status == PHAuthorizationStatus.authorized {
                    self.exportImagesToPhotoLibrary(images: exportList){ numCopied, numErrors in
                        AppData.shared.saveLocally()
                        DispatchQueue.main.async {
                            self.stopSpinner(spinner)
                            if numErrors == 0{
                                self.showDone(title: "success".localize(), text: "imagesExported".localize(i: numCopied))
                            }
                            else{
                                self.showAlert(title: "error".localize(), text: "imagesExportedWithErrors".localize(i1: numCopied, i2: numErrors))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func exportImagesToPhotoLibrary(images: Array<ImageItem>, result: @escaping (Int, Int) -> Void){
        var numCopied = 0
        var numErrors = 0
        for item in images{
            if let data = item.getFile(){
                if item.type == .image{
                    PhotoLibrary.savePhoto(photoData: data, fileType: .jpg, location: CLLocation(coordinate: item.place.coordinate, altitude: item.place.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: item.creationDate), resultHandler: { localIdentifier in
                        if !localIdentifier.isEmpty{
                            numCopied += 1
                        }
                        else{
                            numErrors += 1
                        }
                        if numErrors + numCopied == images.count{
                            result(numCopied, numErrors)
                        }
                    })
                }
            }
            else{
                numErrors += 1
                if numErrors + numCopied == images.count{
                    result(numCopied, numErrors)
                }
            }
        }
    }
    
    func deleteSelected(){
        var list = Array<ImageItem>()
        for i in 0..<images.count{
            let image = images[i]
            if image.selected{
                list.append(image)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "confirmDeleteImages".localize(i: list.count), text: "deleteHint".localize()){
            for image in list{
                image.place.deleteItem(item: image)
                self.images.remove(image)
                Log.debug("deleting image \(image.fileURL.lastPathComponent)")
            }
            AppData.shared.saveLocally()
            self.images = AppData.shared.places.imageItems
            self.setupData()
            self.placeDelegate?.placesChanged()
            self.tableView.reloadData()
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        images.deselectAll()
        super.dismiss(animated: flag, completion: completion)
    }
    
}

extension ImageListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        days.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = days[section]
        return day.images.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let day = days[section]
        let header = TableSectionHeader()
        header.setupView(title: day.date.dateString())
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.CELL_IDENT, for: indexPath) as! ImageCell
        let day = days[indexPath.section]
        cell.useShortDate = true
        cell.image = day.images[indexPath.row]
        cell.placeDelegate = self
        cell.imageDelegate = self
        cell.updateCell(isEditing: tableView.isEditing)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension ImageListViewController : PlaceDelegate{
    
    func placeChanged(place: Place) {
        self.placeDelegate?.placeChanged(place: place)
    }
    
    func placesChanged() {
        self.placeDelegate?.placesChanged()
    }
    
    
    func showPlaceOnMap(place: Place) {
        self.dismiss(animated: true){
            self.placeDelegate?.showPlaceOnMap(place: place)
        }
    }
}

extension ImageListViewController : ImageDelegate{
    
    func viewImage(image: ImageItem) {
        let controller = ImageViewController()
        controller.uiImage = image.getImage()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

