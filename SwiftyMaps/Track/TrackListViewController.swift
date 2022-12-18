/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreLocation

protocol TrackListDelegate{
    func showTrackOnMap(track: Track)
    func deleteTrack(track: Track, approved: Bool)
    func deleteAllTracks()
    func cancelActiveTrack()
    func saveActiveTrack()
}

class TrackListViewController: PopupTableViewController{

    private static let CELL_IDENT = "trackCell"
    
    var tracks: TrackList? = nil
    
    // MainViewController
    var delegate: TrackListDelegate? = nil
    
    override open func loadView() {
        title = "trackList".localize()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackListViewController.CELL_IDENT)
    }
    
    override func setupHeaderView(){
        super.setupHeaderView()
        
        let deleteButton = UIButton().asIconButton("trash", color: .red)
        headerView.addSubviewWithAnchors(deleteButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        deleteButton.addTarget(self, action: #selector(deleteAllTracks), for: .touchDown)
        
        let loadButton = UIButton().asIconButton("arrow.down.square", color: .white)
        headerView.addSubviewWithAnchors(loadButton, top: headerView.topAnchor, leading: deleteButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        loadButton.addTarget(self, action: #selector(loadTrack), for: .touchDown)
    }
    
    @objc func deleteAllTracks(){
        showDestructiveApprove(title: "confirmDeleteAllTracks".localize(), text: "deleteAllTracksHint".localize()){
            self.delegate?.deleteAllTracks()
            self.tableView.reloadData()
        }
    }
    
    @objc func loadTrack(){
        let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "gpx")!])
        filePicker.directoryURL = FileController.gpxDirURL
        filePicker.allowsMultipleSelection = false
        filePicker.delegate = self
        filePicker.modalPresentationStyle = .fullScreen
        self.present(filePicker, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackListViewController.CELL_IDENT, for: indexPath) as! TrackCell
        let track = tracks?[indexPath.row]
        cell.track = track
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
    
    func showTrackOnMap(track: Track) {
        self.dismiss(animated: true){
            self.delegate?.showTrackOnMap(track: track)
        }
    }
    
}


extension TrackListViewController : TrackCellDelegate{
    
    func viewTrackDetails(track: Track) {
        let trackController = TrackDetailViewController()
        trackController.track = track
        trackController.delegate = self
        trackController.modalPresentationStyle = .fullScreen
        self.present(trackController, animated: true)
    }
    
    func exportTrack(track: Track) {
        if let url = GPXCreator.createTemporaryFile(track: track){
            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
            present(controller, animated: true) {
                FileController.logFileInfo()
            }
        }
    }
    
    func deleteTrack(track: Track, approved: Bool) {
        if approved{
            self.deleteTrack(track: track)
        }
        else{
            showDestructiveApprove(title: "confirmDeleteTrack".localize(), text: "deleteTrackHint".localize()){
                self.deleteTrack(track: track)
            }
        }
    }
    
    private func deleteTrack(track: Track){
        delegate?.deleteTrack(track: track, approved: true)
        tracks?.remove(track)
        tableView.reloadData()
    }
    
    func cancelActiveTrack() {
        delegate?.cancelActiveTrack()
    }
    
    func saveActiveTrack() {
        delegate?.saveActiveTrack()
    }
    
}

extension TrackListViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if let trackpoints = GPXParser.parseFile(url: url){
                if let startPosition = trackpoints.first{
                    assertLocation(coordinate: startPosition.coordinate){ location in
                        let track = Track()
                        for loc in trackpoints{
                            track.trackpoints.append(TrackPoint(location: loc))
                        }
                        track.evaluateTrackpoints()
                        let alertController = UIAlertController(title: "name".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
                        alertController.addTextField()
                        alertController.addAction(UIAlertAction(title: "ok".localize(),style: .default) { action in
                            track.name = alertController.textFields![0].text ?? url.lastPathComponent
                            TrackPool.addTrack(track: track)
                            LocationPool.save()
                            self.tracks?.append(track)
                            self.tableView.reloadData()
                        })
                        self.present(alertController, animated: true)
                    }
                }
            }
        }
    }
    
}
