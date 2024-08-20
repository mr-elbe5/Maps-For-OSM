/*
Maps For OSM
App for display and use of OSM maps without MapKit
Copyright: Michael Rönnau mr@elbe5.de
*/

import AppKit
import CoreLocation
import E5Data


protocol LocationGroupDelegate{
    func showLocationDetails(_ location: Location)
}

class LocationGroupDetailView: MapDetailView {
    
    var group: LocationGroup
    
    var selectAllButton: NSButton!
    var mergeSelectedButton: NSButton!
    var deleteSelectedButton: NSButton!
    
    var delegate: LocationGroupDelegate? = nil
    
    override var centerCoordinate: CLLocationCoordinate2D?{
        group.centralCoordinate
    }
    
    init(group: LocationGroup){
        self.group = group
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setupView(){
        createFixedView()
        super.setupView()
    }
    
    override func setupMenuView(){
        selectAllButton = NSButton(icon: "checkmark.square", target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        menuView.addSubviewWithAnchors(selectAllButton, top: menuView.topAnchor, leading: menuView.leadingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        mergeSelectedButton = NSButton(icon: "arrow.triangle.merge", target: self, action: #selector(mergeSelected))
        mergeSelectedButton.toolTip = "mergeSelected".localize()
        menuView.addSubviewWithAnchors(mergeSelectedButton, top: menuView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        deleteSelectedButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteSelectedButton.toolTip = "deleteSelected".localize()
        menuView.addSubviewWithAnchors(deleteSelectedButton, top: menuView.topAnchor, leading: mergeSelectedButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        super.setupMenuView()
    }
    
    override func setupFixedView() {
        if let fixedView = fixedView{
            let header = NSTextField(labelWithString: "center".localize())
            fixedView.addSubviewWithAnchors(header, top: fixedView.topAnchor, leading: fixedView.leadingAnchor, insets: defaultInsets)
            let coordinateLabel = NSTextField(labelWithString: group.centralCoordinate?.asString ?? "")
            fixedView.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: fixedView.leadingAnchor, trailing: fixedView.trailingAnchor, bottom: fixedView.bottomAnchor, insets: defaultInsets)
        }
    }
    
    override func setupContentView(){
        contentView.removeAllSubviews()
        var lastView: NSView? = nil
        for location in group.locations{
            let locationCell = LocationCellView(location: location)
            contentView.addSubviewWithAnchors(locationCell, top: lastView?.bottomAnchor ?? contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            locationCell.delegate = self
            lastView = locationCell
            locationCell.setupView()
        }
        lastView?.bottom(contentView.bottomAnchor, inset: defaultInset)
    }
    
    @objc func toggleSelectAll(){
        if group.locations.allSelected{
            group.locations.deselectAll()
        }
        else{
            group.locations.selectAll()
        }
        for subview in contentView.subviews{
            if let cell = subview as? LocationCellView {
                cell.updateIconView()
            }
        }
    }
    
    @objc func mergeSelected(){
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
        if NSAlert.acceptWarning(title: "confirmMergeLocations".localize(i: list.count), message: "mergeHint".localize()){
            Log.debug("merging \(list.count) locations")
            group.locations.removeLocations(of: list)
            if let newLocation = self.mergeLocations(list){
                AppData.shared.locations.append(newLocation)
                AppData.shared.locations.removeLocations(of: list)
                AppData.shared.save()
                MainViewController.instance.locationsChanged()
                setupContentView()
                MainViewController.instance.locationsChanged()
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
    
    @objc func deleteSelected(){
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
        if NSAlert.acceptWarning(title: "confirmDeleteLocations".localize(i: list.count), message: "deleteHint".localize()){
            print("deleting \(list.count) items")
            for location in list{
                self.group.locations.remove(obj: location)
                location.deleteAllItems()
                AppData.shared.locations.remove(location)
            }
            MainViewController.instance.locationsChanged()
            self.setupContentView()
        }
    }
    
}

extension LocationGroupDetailView: LocationCellDelegate{
    
    func showLocationDetails(_ location: Location) {
        delegate?.showLocationDetails(location)
    }
    
}
