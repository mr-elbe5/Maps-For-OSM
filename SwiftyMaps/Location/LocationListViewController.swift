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
    func deleteLocationFromList(location: Location)
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
    
    func deleteLocationFromCell(location: Location) {
        showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationHint".localize()){
            self.delegate?.deleteLocationFromList(location: location)
            self.tableView.reloadData()
        }
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

