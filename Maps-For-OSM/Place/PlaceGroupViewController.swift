/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol PlaceGroupDelegate: PlaceViewDelegate{
    func showPlaceOnMap(place: Place)
    func deletePlaceFromList(place: Place)
}

class PlaceGroupViewController: PopupViewController{
    
    private static let CELL_IDENT = "placeCell"
    
    var tableView = UITableView()
    
    var group: PlaceGroup
    
    var delegate: PlaceGroupDelegate? = nil
    
    init(group: PlaceGroup){
        self.group = group
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceGroupViewController.CELL_IDENT)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "placeGroup".localize()
        super.loadView()
        let guide = view.safeAreaLayoutGuide
        
        var header = UILabel(header: "center".localize())
        view.addSubviewWithAnchors(header, top: headerView?.bottomAnchor, leading: guide.leadingAnchor, insets: defaultInsets)
        
        let coordinateLabel = UILabel(text: group.centralCoordinate?.asString ?? "")
        view.addSubviewWithAnchors(coordinateLabel, top: header.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, insets: flatInsets)
        
        header = UILabel(header: "places".localize())
        view.addSubviewWithAnchors(header, top: coordinateLabel.bottomAnchor, leading: guide.leadingAnchor, insets: defaultInsets)
        
        view.addSubviewWithAnchors(tableView, top: header.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: defaultInsets)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        let mergeButton = UIButton().asIconButton("arrow.triangle.merge", color: .label)
        headerView.addSubviewWithAnchors(mergeButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: wideInsets)
        mergeButton.addAction(UIAction(){ action in
            self.mergePlaces()
        }, for: .touchDown)
        
    }
    
    func setNeedsUpdate(){
        tableView.reloadData()
    }
    
    func mergePlaces(){
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceGroupViewController.CELL_IDENT, for: indexPath) as! PlaceCell
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




