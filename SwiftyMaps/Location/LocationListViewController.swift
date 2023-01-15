/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

protocol LocationListDelegate: LocationViewDelegate{
    func showLocationOnMap(location: Location)
    func deleteLocation(location: Location)
    func deleteAllLocations()
}

class LocationListViewController: PopupTableViewController{

    private static let CELL_IDENT = "locationCell"
    
    var delegate: LocationListDelegate? = nil
    
    override func loadView() {
        title = "locationList".localize()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationListViewController.CELL_IDENT)
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        let deleteButton = UIButton().asIconButton("trash", color: .red)
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addTarget(self, action: #selector(deleteAllLocations), for: .touchDown)
    }
    
    @objc func deleteAllLocations(){
        showDestructiveApprove(title: "confirmDeleteLocations".localize(), text: "deleteLocationsHint".localize()){
            self.delegate?.deleteAllLocations()
            self.tableView.reloadData()
        }
    }
    
}

extension LocationListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LocationPool.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationListViewController.CELL_IDENT, for: indexPath) as! LocationCell
        let track = LocationPool.location(at: indexPath.row)
        cell.location = track
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

extension LocationListViewController : LocationCellDelegate{
    
    func showLocationOnMap(location: Location) {
        self.dismiss(animated: true){
            self.delegate?.showLocationOnMap(location: location)
        }
    }
    
    func deleteLocation(location: Location, approved: Bool) {
        if approved{
            deleteLocation(place: location)
        }
        else{
            showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationInfo".localize()){
                self.deleteLocation(place: location)
            }
        }
    }
    
    private func deleteLocation(place: Location){
        delegate?.deleteLocation(location: place)
        self.tableView.reloadData()
    }
    
    func viewLocation(location: Location) {
        let placeController = LocationDetailViewController(location: location)
        placeController.delegate = self
        placeController.location = location
        placeController.modalPresentationStyle = .fullScreen
        self.present(placeController, animated: true)
    }
    
}

extension LocationListViewController: LocationViewDelegate{
    
    func updateMarkerLayer() {
        delegate?.updateMarkerLayer()
    }
    
}

