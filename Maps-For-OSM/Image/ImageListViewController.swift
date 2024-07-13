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

class ImageListViewController: NavTableViewController{
    
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
    
    var delegate: ImageCellDelegate? = nil
    
    var images = ImageList()
    var days = Array<Day>()
    
    var mainViewController: MainViewController?{
        navigationController?.rootViewController as? MainViewController
    }
    
    override open func loadView() {
        title = "images".localize()
        super.loadView()
        images = AppData.shared.locations.images
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
    
    override func updateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            self.images.deselectAll()
            self.navigationController?.popViewController(animated: true)
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "sort".localize(), image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: UIAction(){ action in
            self.sortImages()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "export".localize(), image: UIImage(systemName: "square.and.arrow.up"), primaryAction: UIAction(){ action in
            self.exportSelected()
        }))
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        navigationItem.trailingItemGroups = groups
        
    }
    
    func sortImages(){
        AppState.shared.sortAscending = !AppState.shared.sortAscending
        AppData.shared.locations.sortAll()
        setupData()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if images.allSelected{
            images.deselectAll()
        }
        else{
            images.selectAll()
        }
        for cell in tableView.visibleCells{
            (cell as? ImageCell)?.updateIconView()
        }
    }
    
    func exportSelected(){
        var exportList = Array<Image>()
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
        var list = Array<Image>()
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
                image.location.deleteItem(item: image)
                self.images.remove(image)
                Log.debug("deleting image \(image.fileURL.lastPathComponent)")
            }
            AppData.shared.save()
            self.images = AppData.shared.locations.images
            self.setupData()
            self.mainViewController?.locationsChanged()
            self.tableView.reloadData()
        }
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
        cell.delegate = self
        cell.updateCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension ImageListViewController : ImageCellDelegate{
    
    func locationChanged(location: Location) {
        mainViewController?.locationChanged(location: location)
    }
    
    func locationsChanged() {
        mainViewController?.locationsChanged()
    }
    
    func showLocationOnMap(coordinate: CLLocationCoordinate2D) {
        navigationController?.popToRootViewController(animated: true)
        mainViewController?.showLocationOnMap(coordinate: coordinate)
    }
    
    func viewImage(image: Image) {
        let controller = ImageViewController()
        controller.uiImage = image.getImage()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

