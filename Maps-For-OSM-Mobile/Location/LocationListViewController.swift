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


class LocationListViewController: NavTableViewController{
    
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
        title = "locations".localize()
        setupData()
        super.loadView()
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationListCell.self, forCellReuseIdentifier: LocationListCell.LOCATION_CELL_IDENT)
    }
    
    override func updateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            AppData.shared.locations.deselectAll()
            self.close()
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "sort".localize(), image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: UIAction(){ action in
            self.sortLocations()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        navigationItem.trailingItemGroups = groups
        
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
            (cell as? LocationCell)?.updateIconView()
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
            self.setupData()
            self.tableView.reloadData()
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationListCell.LOCATION_CELL_IDENT, for: indexPath) as! LocationListCell
        let day = days[indexPath.section]
        cell.location = day.locations[indexPath.row]
        cell.locationDelegate = self
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

extension LocationListViewController : LocationDelegate{
    
    func showLocationOnMap(coordinate: CLLocationCoordinate2D) {
        navigationController?.popToRootViewController(animated: true)
        locationDelegate?.showLocationOnMap(coordinate: coordinate)
    }
    
    func editLocation(location: Location) {
        let controller = LocationViewController(location: location)
        controller.location = location
        controller.locationDelegate = self
        controller.trackDelegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func locationsChanged() {
        tableView.reloadData()
        locationDelegate?.locationsChanged()
    }
    
    func locationChanged(location: Location) {
        tableView.reloadData()
        locationDelegate?.locationChanged(location: location)
    }
    
}

extension LocationListViewController: TrackDelegate{
    
    func showTrackOnMap(track: TrackItem) {
        trackDelegate?.showTrackOnMap(track: track)
    }
    
}




