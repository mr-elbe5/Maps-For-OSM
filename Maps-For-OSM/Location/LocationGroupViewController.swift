/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData

class LocationGroupViewController: TableViewController{
    
    var group: LocationGroup
    
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let mergeButton = UIButton().asIconButton("arrow.triangle.merge", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
    
    var locationDelegate: LocationDelegate? = nil
    var trackDelegate: TrackDelegate? = nil
    
    init(group: LocationGroup){
        self.group = group
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.CELL_IDENT)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "locationGroup".localize()
        createSubheaderView()
        super.loadView()
    }
    
    override func updateNavigationItems() {
        super.updateNavigationItems()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            AppData.shared.locations.deselectAll()
            self.navigationController?.popViewController(animated: true)
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "merge".localize(), image: UIImage(systemName: "arrow.triangle.merge"), primaryAction: UIAction(){ action in
            self.mergeSelected()
        }))
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        navigationItem.trailingItemGroups = groups
        
    }
    
    override func setupSubheaderView(subheaderView: UIView) {
        
        var header = UILabel(header: "center".localize())
        subheaderView.addSubviewWithAnchors(header, top: subheaderView.topAnchor, leading: subheaderView.leadingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: group.centralCoordinate?.asString ?? "")
        subheaderView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: flatInsets)
        
        header = UILabel(header: "locations".localize())
        subheaderView.addSubviewWithAnchors(header, top: coordinateLabel.bottomAnchor, leading: subheaderView.leadingAnchor, bottom: subheaderView.bottomAnchor, insets: defaultInsets)
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
        for i in 0..<group.locations.count{
            let location = group.locations[i]
            if location.selected{
                list.append(location)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "confirmDeleteLocations".localize(i: list.count), text: "deleteHint".localize()){
            print("deleting \(list.count) locations")
            for location in list{
                AppData.shared.deleteLocation(location)
                self.group.locations.remove(location)
            }
            self.locationDelegate?.locationsChanged()
            self.tableView.reloadData()
        }
    }
    
    func mergeSelected(){
        var list = LocationList()
        for i in 0..<group.locations.count{
            let location = group.locations[i]
            if location.selected{
                list.append(location)
            }
        }
        if list.isEmpty{
            return
        }
        showDestructiveApprove(title: "confirmMergeLocations".localize(i: list.count), text: "mergeHint".localize()){
            Log.debug("merging \(list.count) locations")
            if let newLocation = self.mergeLocations(list){
                AppData.shared.locations.append(newLocation)
                AppData.shared.locations.removeLocations(of: list)
                AppData.shared.save()
                self.locationDelegate?.locationsChanged()
                self.tableView.reloadData()
            }
        }
    }
    
    private func mergeLocations(_ locations: LocationList) -> Location?{
        let count = locations.count
        if count < 2{
            return nil
        }
        var lat = 0.0
        var lon = 0.0
        var timestamp = Date.localDate
        for location in locations{
            lat += location.coordinate.latitude
            lon += location.coordinate.longitude
            if location.creationDate < timestamp{
                timestamp = location.creationDate
            }
        }
        lat = lat/Double(count)
        lon = lon/Double(count)
        let newLocation = Location(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        newLocation.evaluatePlacemark()
        newLocation.creationDate = timestamp
        for location in locations{
            for item in location.items{
                newLocation.addItem(item: item)
            }
        }
        newLocation.sortItems()
        return newLocation
    }
    
}

extension LocationGroupViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        group.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.CELL_IDENT, for: indexPath) as! LocationCell
        cell.location = group.locations[indexPath.row]
        cell.delegate = self
        cell.updateCell()
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

extension LocationGroupViewController : LocationCellDelegate{
    
    func showLocationOnMap(location: Location) {
        self.close()
        self.locationDelegate?.showLocationOnMap(location: location)
    }
    
    func editLocation(location: Location) {
        let controller = EditLocationViewController(location: location)
        controller.location = location
        controller.locationDelegate = self
        controller.trackDelegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension LocationGroupViewController : LocationDelegate{
    
    func locationChanged(location: Location) {
        locationDelegate?.locationChanged(location: location)
    }
    
    func locationsChanged() {
        locationDelegate?.locationsChanged()
    }
    
}

extension LocationGroupViewController : TrackDelegate{
    
    func editTrack(item: Track) {
        let controller = EditTrackViewController(track: item)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showTrackOnMap(item: Track) {
        self.close()
        self.trackDelegate?.showTrackOnMap(item: item)
    }
    
}


