/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData

class PlaceListViewController: PopupTableViewController{
    
    class Day{
        
        var date: Date
        var places = PlaceList()
        
        init(_ date: Date){
            self.date = date
        }
        
    }
    
    let sortButton = UIButton().asIconButton("arrow.up.arrow.down", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash.square", color: .systemRed)

    var placeDelegate: PlaceDelegate? = nil
    var trackDelegate: TrackDelegate? = nil
    
    var days = Array<Day>()
    
    override func loadView() {
        title = "placeList".localize()
        super.loadView()
        setupData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.CELL_IDENT)
    }
    
    func setupData(){
        days.removeAll()
        for place in AppData.shared.places{
            let startOfDay = place.creationDate.startOfDay()
            if let day = days.first(where: { day in
                day.date == startOfDay
            }){
                day.places.append(place)
            }
            else{
                let day = Day(startOfDay)
                day.places.append(place)
                days.append(day)
            }
        }
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        let buttonTopAnchor = titleLabel?.bottomAnchor ?? headerView.topAnchor
        
        headerView.addSubviewWithAnchors(sortButton, top: buttonTopAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        sortButton.addAction(UIAction(){ action in
            self.sortPlaces()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(selectAllButton, top: buttonTopAnchor, leading: sortButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        selectAllButton.addAction(UIAction(){ action in
            self.toggleSelectAll()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(deleteButton, top: buttonTopAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
    }
    
    func sortPlaces(){
        AppState.shared.sortAscending = !AppState.shared.sortAscending
        AppData.shared.places.sortAll()
        setupData()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
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
    
    func deleteSelected(){
        var list = PlaceList()
        for i in 0..<AppData.shared.places.count{
            let place = AppData.shared.places[i]
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
            }
            self.placeDelegate?.placesChanged()
            self.setupData()
            self.tableView.reloadData()
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        AppData.shared.places.deselectAll()
        super.dismiss(animated: flag, completion: completion)
    }
    
}

extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = days[section]
        return day.places.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let day = days[section]
        let header = TableSectionHeader()
        header.setupView(title: day.date.dateString())
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.CELL_IDENT, for: indexPath) as! PlaceCell
        let day = days[indexPath.section]
        cell.place = day.places[indexPath.row]
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

extension PlaceListViewController : PlaceCellDelegate{
    
    func showPlaceOnMap(place: Place) {
        self.dismiss(animated: true){
            self.placeDelegate?.showPlaceOnMap(place: place)
        }
    }
    
    func editPlace(place: Place) {
        let placeController = EditPlaceViewController(location: place)
        placeController.place = place
        placeController.placeDelegate = self
        placeController.trackDelegate = self
        placeController.modalPresentationStyle = .fullScreen
        self.present(placeController, animated: true)
    }
    
}

extension PlaceListViewController : PlaceDelegate{
    
    func placeChanged(place: Place) {
        placeDelegate?.placeChanged(place: place)
    }
    
    func placesChanged() {
        placeDelegate?.placesChanged()
    }
    
}

extension PlaceListViewController : TrackDelegate{
    
    func editTrackItem(item: TrackItem) {
        let controller = EditTrackViewController(track: item)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func showTrackItemOnMap(item: TrackItem) {
        self.dismiss(animated: true){
            self.trackDelegate?.showTrackItemOnMap(item: item)
        }
    }
    
}



