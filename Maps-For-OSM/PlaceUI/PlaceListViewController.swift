/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

class PlaceListViewController: PopupTableViewController{
    
    let editModeButton = UIButton().asIconButton("pencil.circle", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .systemRed)

    var delegate: PlaceDelegate? = nil
    
    override func loadView() {
        title = "placeList".localize()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.CELL_IDENT)
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
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
        deleteButton.isHidden = !tableView.isEditing
        
        let infoButton = UIButton().asIconButton("info.circle")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = PlaceListInfoViewController()
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    func toggleEditMode(){
        if tableView.isEditing{
            editModeButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            tableView.isEditing = false
            selectAllButton.isHidden = true
            deleteButton.isHidden = true
        }
        else{
            editModeButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            tableView.isEditing = true
            selectAllButton.isHidden = false
            deleteButton.isHidden = false
        }
        PlacePool.places.deselectAll()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if tableView.isEditing{
            if PlacePool.places.allSelected{
                PlacePool.places.deselectAll()
            }
            else{
                PlacePool.places.selectAll()
            }
            for cell in tableView.visibleCells{
                (cell as? PlaceCell)?.updateIconView(isEditing: true)
            }
        }
    }
    
    func deleteSelected(){
        var list = PlaceList()
        for i in 0..<PlacePool.places.count{
            let place = PlacePool.places[i]
            if place.selected{
                list.append(place)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "confirmDeletePlaces".localize(i: list.count), text: "deleteHint".localize()){
            print("deleting \(list.count) places")
            for place in list{
                PlacePool.deletePlace(place)
            }
            self.delegate?.placesChanged()
            self.tableView.reloadData()
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        PlacePool.places.deselectAll()
        super.dismiss(animated: flag, completion: completion)
    }
    
}

extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PlacePool.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.CELL_IDENT, for: indexPath) as! PlaceCell
        cell.place = PlacePool.places[indexPath.row]
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

extension PlaceListViewController : PlaceCellDelegate{
    
    func showPlaceOnMap(place: Place) {
        self.dismiss(animated: true){
            self.delegate?.showPlaceOnMap(place: place)
        }
    }
    
    func viewPlace(place: Place) {
        let placeController = PlaceViewController(location: place)
        placeController.place = place
        placeController.modalPresentationStyle = .fullScreen
        self.present(placeController, animated: true)
    }
    
}


