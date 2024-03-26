/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

protocol TrackListDelegate{
    func showTrackItemOnMap(item: TrackItem)
    func placesChanged()
}

//todo: edit mode, selection

class TrackListViewController: PopupTableViewController{

    private static let CELL_IDENT = "trackCell"
    
    var tracks: TrackList? = nil
    
    let editModeButton = UIButton().asIconButton("pencil.circle", color: .label)
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
    
    var delegate: TrackListDelegate? = nil
    
    override open func loadView() {
        title = "trackList".localize()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackItemCell.self, forCellReuseIdentifier: TrackListViewController.CELL_IDENT)
    }
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        
        headerView.addSubviewWithAnchors(editModeButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        editModeButton.addAction(UIAction(){ action in
            self.toggleEditMode()
        }, for: .touchDown)
        
        headerView.addSubviewWithAnchors(selectAllButton, top: headerView.topAnchor, leading: editModeButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        selectAllButton.addAction(UIAction(){ action in
            self.toggleSelectAll()
        }, for: .touchDown)
        selectAllButton.isHidden = !tableView.isEditing
        
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addAction(UIAction(){ action in
            self.deleteSelected()
        }, for: .touchDown)
        deleteButton.isHidden = !tableView.isEditing
    }
    
    func toggleEditMode(){
        if tableView.isEditing{
            editModeButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            tableView.isEditing = false
            selectAllButton.isHidden = true
            deleteButton.isHidden = true
        }
        else{
            editModeButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            tableView.isEditing = true
            selectAllButton.isHidden = false
            deleteButton.isHidden = false
        }
        tracks?.deselectAll()
        tableView.reloadData()
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
                (cell as? TrackItemCell)?.updateIconView(isEditing: true)
            }
        }
    }
    
    func deleteSelected(){
        if let tracks = tracks{
            var list = TrackList()
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
                PlacePool.save()
                self.delegate?.placesChanged()
                self.tableView.reloadData()
            }
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        tracks?.deselectAll()
        super.dismiss(animated: flag, completion: completion)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackListViewController.CELL_IDENT, for: indexPath) as! TrackItemCell
        let track = tracks?.reversed()[indexPath.row]
        cell.trackItem = track
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

extension TrackListViewController : TrackDetailDelegate{
    
    func showTrackItemOnMap(item: TrackItem) {
        self.dismiss(animated: true){
            self.delegate?.showTrackItemOnMap(item: item)
        }
    }
    
}

extension TrackListViewController : TrackItemCellDelegate{
    
    func viewTrackItem(item: TrackItem) {
        let trackController = TrackViewController(track: item)
        trackController.track = item
        trackController.delegate = self
        trackController.modalPresentationStyle = .fullScreen
        self.present(trackController, animated: true)
    }
    
    func exportTrack(item: TrackItem) {
        if let url = GPXCreator.createTemporaryFile(track: item){
            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
            controller.directoryURL = FileController.exportGpxDirURL
            present(controller, animated: true) {
                FileController.logFileInfo()
            }
        }
    }
    
}
