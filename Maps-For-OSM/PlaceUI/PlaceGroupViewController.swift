/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation

class PlaceGroupViewController: PopupTableViewController{
    
    var group: PlaceGroup
    
    let editModeButton = UIButton().asIconButton("pencil", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let mergeButton = UIButton().asIconButton("arrow.triangle.merge", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
    
    var delegate: PlaceDelegate? = nil
    
    init(group: PlaceGroup){
        self.group = group
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.CELL_IDENT)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "placeGroup".localize()
        createSubheaderView()
        super.loadView()
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
        
        headerView.addSubviewWithAnchors(mergeButton, top: headerView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        mergeButton.addAction(UIAction(){ action in
            self.mergeSelected()
        }, for: .touchDown)
        mergeButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: mergeButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
        deleteButton.isHidden = !tableView.isEditing
        
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = PlaceGroupInfoViewController()
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    override func setupSubheaderView(subheaderView: UIView) {
        
        var header = UILabel(header: "center".localize())
        subheaderView.addSubviewWithAnchors(header, top: subheaderView.topAnchor, leading: subheaderView.leadingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: group.centralCoordinate?.asString ?? "")
        subheaderView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: flatInsets)
        
        header = UILabel(header: "places".localize())
        subheaderView.addSubviewWithAnchors(header, top: coordinateLabel.bottomAnchor, leading: subheaderView.leadingAnchor, bottom: subheaderView.bottomAnchor, insets: defaultInsets)
    }
    
    func toggleEditMode(){
        if tableView.isEditing{
            editModeButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            tableView.isEditing = false
            selectAllButton.isHidden = true
            mergeButton.isHidden = true
            deleteButton.isHidden = true
        }
        else{
            editModeButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            tableView.isEditing = true
            selectAllButton.isHidden = false
            mergeButton.isHidden = false
            deleteButton.isHidden = false
        }
        AppData.shared.places.deselectAll()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if tableView.isEditing{
            if AppData.shared.places.allSelected{
                AppData.shared.places.deselectAll()
            }
            else{
                AppData.shared.places.selectAll()
            }
            for cell in tableView.visibleCells{
                (cell as? PlaceCell)?.updateIconView(isEditing: true)
            }
        }
    }
    
    func deleteSelected(){
        var list = Array<Place>()
        for i in 0..<group.places.count{
            let place = group.places[i]
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
                AppData.shared.deletePlace(place)
                self.group.places.remove(place)
            }
            self.delegate?.placesChanged()
            self.tableView.reloadData()
        }
    }
    
    func mergeSelected(){
        var list = Array<Place>()
        for i in 0..<group.places.count{
            let place = group.places[i]
            if place.selected{
                list.append(place)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "confirmMergePlaces".localize(i: list.count), text: "mergeHint".localize()){
            print("merging \(list.count) places")
            if let newPlace = self.mergePlaces(list){
                AppData.shared.places.append(newPlace)
                AppData.shared.places.removePlaces(of: list)
                AppData.shared.saveLocally()
                self.delegate?.placesChanged()
                self.tableView.reloadData()
            }
        }
    }
    
    private func mergePlaces(_ places: Array<Place>) -> Place?{
        let count = places.count
        if count < 2{
            return nil
        }
        var lat = 0.0
        var lon = 0.0
        var timestamp = Date()
        for place in places{
            lat += place.coordinate.latitude
            lon += place.coordinate.longitude
            if place.timestamp < timestamp{
                timestamp = place.timestamp
            }
        }
        lat = lat/Double(count)
        lon = lon/Double(count)
        let newPlace = Place(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        newPlace.evaluatePlacemark()
        newPlace.timestamp = timestamp
        for place in places{
            for item in place.allItems{
                newPlace.addItem(item: item)
            }
        }
        newPlace.sortItems()
        return newPlace
    }
    
}

extension PlaceGroupViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        group.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.CELL_IDENT, for: indexPath) as! PlaceCell
        cell.place = group.places[indexPath.row]
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

extension PlaceGroupViewController : PlaceCellDelegate{
    
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




