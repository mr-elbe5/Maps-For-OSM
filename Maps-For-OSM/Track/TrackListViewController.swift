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

class TrackListViewController: PopupTableViewController{

    var tracks: Array<TrackItem>? = nil
    
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash.square", color: .systemRed)
    
    var placeDelegate: PlaceDelegate? = nil
    var trackDelegate: TrackDelegate? = nil
    
    override open func loadView() {
        title = "trackList".localize()
        super.loadView()
        tracks?.sortByDate()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.CELL_IDENT)
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        let buttonTopAnchor = titleLabel?.bottomAnchor ?? headerView.topAnchor
        
        headerView.addSubviewWithAnchors(selectAllButton, top: buttonTopAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        selectAllButton.addAction(UIAction(){ action in
            self.toggleSelectAll()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(deleteButton, top: buttonTopAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
        
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: buttonTopAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = TrackListInfoViewController()
            self.present(controller, animated: true)
        }, for: .touchDown)
    }
    
    func toggleSelectAll(){
        if tableView.isEditing, var tracks = tracks{
            if tracks.allSelected{
                tracks.deselectAll()
            }
            else{
                tracks.selectAll()
            }
            for cell in tableView.visibleCells{
                (cell as? TrackCell)?.updateIconView(isEditing: true)
            }
        }
    }
    
    func deleteSelected(){
        if let tracks = tracks{
            var list = Array<TrackItem>()
            for i in 0..<tracks.count{
                let track = tracks[i]
                if track.selected{
                    list.append(track)
                }
            }
            if list.isEmpty{
                return
            }
            showDestructiveApprove(title: "confirmDeleteTracks".localize(i: list.count), text: "deleteHint".localize()){
                for track in list{
                    track.place.deleteItem(item: track)
                    self.tracks?.remove(track)
                    Log.debug("deleting track \(track.name)")
                }
                AppData.shared.saveLocally()
                self.placeDelegate?.placesChanged()
                self.tableView.reloadData()
            }
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        tracks?.deselectAll()
        super.dismiss(animated: flag, completion: completion)
    }
    
    func exportTrack(item: TrackItem) {
        if let url = GPXCreator.createTemporaryFile(track: item){
            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
            controller.directoryURL = FileManager.exportGpxDirURL
            present(controller, animated: true) {
                FileManager.default.logFileInfo()
            }
        }
    }
    
}

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.CELL_IDENT, for: indexPath) as! TrackCell
        let track = tracks?.reversed()[indexPath.row]
        cell.track = track
        cell.placeDelegate = self
        cell.trackDelegate = self
        cell.updateCell(isEditing: tableView.isEditing)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension TrackListViewController : PlaceDelegate{
    
    func placeChanged(place: Place) {
        self.placeDelegate?.placeChanged(place: place)
    }
    
    func placesChanged() {
        self.placeDelegate?.placesChanged()
    }
    
    func showPlaceOnMap(place: Place) {
        self.placeDelegate?.showPlaceOnMap(place: place)
    }
    
}
    
extension TrackListViewController : TrackDelegate{
    
    func editTrackItem(item: TrackItem) {
        let trackController = EditTrackViewController(track: item)
        trackController.track = item
        trackController.delegate = self
        trackController.modalPresentationStyle = .fullScreen
        self.present(trackController, animated: true)
    }
    
    func showTrackItemOnMap(item: TrackItem) {
        self.dismiss(animated: true){
            self.trackDelegate?.showTrackItemOnMap(item: item)
        }
    }
    
}
