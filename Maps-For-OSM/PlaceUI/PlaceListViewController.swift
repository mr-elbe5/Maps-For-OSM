/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

protocol PlaceListDelegate: PlaceViewDelegate{
    func showPlaceOnMap(place: Place)
    func deletePlaceFromList(place: Place)
}

class PlaceListViewController: PopupTableViewController{

    var delegate: PlaceListDelegate? = nil
    
    override func loadView() {
        title = "placeList".localize()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.CELL_IDENT)
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
        cell.place = PlacePool.list[indexPath.row]
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
    
    func deletePlaceFromCell(place: Place) {
        showDestructiveApprove(title: "confirmDeletePlace".localize(), text: "deletePlaceHint".localize()){
            self.delegate?.deletePlaceFromList(place: place)
            self.tableView.reloadData()
        }
    }
    
    func viewPlace(place: Place) {
        let placeController = PlaceViewController(location: place)
        placeController.place = place
        placeController.modalPresentationStyle = .fullScreen
        self.present(placeController, animated: true)
    }
    
}


