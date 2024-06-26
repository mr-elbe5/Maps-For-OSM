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
        let buttonTopAnchor = titleLabel?.bottomAnchor ?? headerView.topAnchor
        
        headerView.addSubviewWithAnchors(sortButton, top: buttonTopAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        sortButton.addAction(UIAction(){ action in
            self.sortImages()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(selectAllButton, top: buttonTopAnchor, leading: sortButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        selectAllButton.addAction(UIAction(){ action in
            self.toggleSelectAll()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(exportSelectedButton, top: buttonTopAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        exportSelectedButton.addAction(UIAction(){ action in
            self.exportSelected()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(deleteButton, top: buttonTopAnchor, leading: exportSelectedButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
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
            var numCopied = 0
            for image in exportList{
                do{
                    let targetURL = FileManager.exportMediaDirURL.appendingPathComponent(image.fileName)
                    if FileManager.default.fileExists(url: targetURL){
                        FileManager.default.deleteFile(url: targetURL)
                    }
                    try FileManager.default.copyItem(at: image.fileURL, to: targetURL)
                    numCopied += 1
                }
                catch (let err){
                    Log.error(err.localizedDescription)
                }
            }
            DispatchQueue.main.async {
                self.stopSpinner(spinner)
                self.showDone(title: "success".localize(), text: "imagesExported".localize(i: numCopied))
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

