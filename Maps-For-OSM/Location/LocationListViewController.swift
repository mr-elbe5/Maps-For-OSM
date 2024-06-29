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

class LocationListViewController: PopupTableViewController{
    
    class Day{
        
        var date: Date
        var locations = LocationList()
        
        init(_ date: Date){
            self.date = date
        }
        
    }
    
    let sortButton = UIButton().asIconButton("arrow.up.arrow.down", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash.square", color: .systemRed)

    var locationDelegate: LocationDelegate? = nil
    var trackDelegate: TrackDelegate? = nil
    
    var days = Array<Day>()
    
    override func loadView() {
        title = "LocationList".localize()
        super.loadView()
        setupData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.CELL_IDENT)
    }
    
    func setupData(){
        days.removeAll()
        for location in AppData.shared.locations{
            let startOfDay = location.creationDate.startOfDay()
            if let day = days.first(where: { day in
                day.date == startOfDay
            }){
                day.locations.append(location)
            }
            else{
                let day = Day(startOfDay)
                day.locations.append(location)
                days.append(day)
            }
        }
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        let buttonTopAnchor = titleLabel?.bottomAnchor ?? headerView.topAnchor
        
        headerView.addSubviewWithAnchors(sortButton, top: buttonTopAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        sortButton.addAction(UIAction(){ action in
            self.sortLocations()
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
    
    func sortLocations(){
        AppState.shared.sortAscending = !AppState.shared.sortAscending
        AppData.shared.locations.sortAll()
        setupData()
        tableView.reloadData()
    }
    
    func toggleSelectAll(){
        if AppData.shared.locations.allSelected{
            AppData.shared.locations.deselectAll()
        }
        else{
            AppData.shared.locations.selectAll()
        }
        for cell in tableView.visibleCells{
            (cell as? LocationCell)?.updateIconView(isEditing: true)
        }
    }
    
    func deleteSelected(){
        var list = LocationList()
        for i in 0..<AppData.shared.locations.count{
            let location = AppData.shared.locations[i]
            if location.selected{
                list.append(location)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "confirmDeleteLocations".localize(i: list.count), text: "deleteHint".localize()){
            Log.debug("deleting \(list.count) locations")
            for location in list{
                AppData.shared.deleteLocation(location)
            }
            self.locationDelegate?.locationsChanged()
            self.setupData()
            self.tableView.reloadData()
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        AppData.shared.locations.deselectAll()
        super.dismiss(animated: flag, completion: completion)
    }
    
}

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = days[section]
        return day.locations.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let day = days[section]
        let header = TableSectionHeader()
        header.setupView(title: day.date.dateString())
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.CELL_IDENT, for: indexPath) as! LocationCell
        let day = days[indexPath.section]
        cell.location = day.locations[indexPath.row]
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

extension LocationListViewController : LocationCellDelegate{
    
    func showLocationOnMap(location: Location) {
        self.dismiss(animated: true){
            self.locationDelegate?.showLocationOnMap(location: location)
        }
    }
    
    func editLocation(location: Location) {
        let controller = EditLocationViewController(location: location)
        controller.location = location
        controller.locationDelegate = self
        controller.trackDelegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
}

extension LocationListViewController : LocationDelegate{
    
    func locationChanged(location: Location) {
        locationDelegate?.locationChanged(location: location)
    }
    
    func locationsChanged() {
        locationDelegate?.locationsChanged()
    }
    
}

extension LocationListViewController : TrackDelegate{
    
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



