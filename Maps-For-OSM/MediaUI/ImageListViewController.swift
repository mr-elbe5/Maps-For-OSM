/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation
import PhotosUI

class ImageListViewController: PopupTableViewController{

    var images: Array<Image>? = nil
    
    let editModeButton = UIButton().asIconButton("pencil", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let exportSelectedButton = UIButton().asIconButton("square.and.arrow.up", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
    
    var delegate: ImageDelegate? = nil
    
    override open func loadView() {
        title = "images".localize()
        super.loadView()
        images?.sortByDate()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.CELL_IDENT)
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        headerView.addSubviewWithAnchors(editModeButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
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
        
        let infoButton = UIButton().asIconButton("info.circle")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = ImageListInfoViewController()
            controller.modalPresentationStyle = .fullScreen
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
        images?.deselectAll()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if tableView.isEditing, var images = images{
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
        if let images = images{
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
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.startAnimating()
            view.addSubview(spinner)
            spinner.setAnchors(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
            DispatchQueue.global(qos: .userInitiated).async {
                PHPhotoLibrary.requestAuthorization(){ status in
                    if status == PHAuthorizationStatus.authorized {
                        self.exportImagesToPhotoLibrary(images: exportList){ numCopied, numErrors in
                            PlacePool.save()
                            DispatchQueue.main.async {
                                spinner.stopAnimating()
                                self.view.removeSubview(spinner)
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
    }
    
    private func exportImagesToPhotoLibrary(images: Array<Image>, result: @escaping (Int, Int) -> Void){
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
        if let images = images{
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
                    image.place.deleteItem(item: image)
                    self.images?.remove(image)
                    Log.debug("deleting image \(image.fileURL.lastPathComponent)")
                }
                PlacePool.save()
                self.delegate?.placesChanged()
                self.tableView.reloadData()
            }
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        images?.deselectAll()
        super.dismiss(animated: flag, completion: completion)
    }
    
}

extension ImageListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        images?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.CELL_IDENT, for: indexPath) as! ImageCell
        let image = images?.reversed()[indexPath.row]
        cell.image = image
        cell.delegate = self
        cell.updateCell(isEditing: tableView.isEditing)
        return cell
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

extension ImageListViewController : ImageDelegate{
    
    func placeChanged(place: Place) {
        self.delegate?.placeChanged(place: place)
    }
    
    func placesChanged() {
        self.delegate?.placesChanged()
    }
    
    
    func showPlaceOnMap(place: Place) {
        self.dismiss(animated: true){
            self.delegate?.showPlaceOnMap(place: place)
        }
    }
    
    func viewImage(image: Image) {
        let controller = ImageViewController()
        controller.uiImage = image.getImage()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

