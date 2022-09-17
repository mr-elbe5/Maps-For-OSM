/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

protocol PlaceListDelegate: LocationViewDelegate{
    func showOnMap(location: Place)
    func deleteLocation(location: Place)
    func showTrackOnMap(track: TrackData)
}

class PlaceListViewController: PopupTableViewController{

    private static let CELL_IDENT = "locationCell"
    
    var delegate: PlaceListDelegate? = nil
    
    override func loadView() {
        title = "locationList".localize()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceListViewController.CELL_IDENT)
    }
    
}

extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Places.size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceListViewController.CELL_IDENT, for: indexPath) as! PlaceCell
        let track = Places.location(at: indexPath.row)
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

extension PlaceListViewController : PlaceCellDelegate{
    
    func showOnMap(location: Place) {
        self.dismiss(animated: true){
            self.delegate?.showOnMap(location: location)
        }
    }
    
    func deleteLocation(location: Place, approved: Bool) {
        if approved{
            deleteLocation(location: location)
        }
        else{
            showDestructiveApprove(title: "confirmDeleteLocation".localize(), text: "deleteLocationInfo".localize()){
                self.deleteLocation(location: location)
            }
        }
    }
    
    private func deleteLocation(location: Place){
        delegate?.deleteLocation(location: location)
        self.tableView.reloadData()
    }
    
    func viewLocation(location: Place) {
        let locationController = PlaceDetailViewController()
        locationController.delegate = self
        locationController.location = location
        locationController.modalPresentationStyle = .fullScreen
        self.present(locationController, animated: true)
    }
    
}

extension PlaceListViewController: LocationViewDelegate{
    
    func updateLocationLayer() {
        delegate?.updateLocationLayer()
    }
    
    func showTrackOnMap(track: TrackData) {
        self.dismiss(animated: true){
            self.delegate?.showTrackOnMap(track: track)
        }
    }
    
}

