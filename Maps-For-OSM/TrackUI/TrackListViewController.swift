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
    func showTrackOnMap(track: TrackItem)
    func deleteTrack(track: TrackItem, approved: Bool)
}

class TrackListViewController: PopupTableViewController{

    private static let CELL_IDENT = "trackCell"
    
    var tracks: TrackList? = nil
    
    var selectMode = false
    
    let selectModeButton = UIButton().asIconButton("checkmark.circle", color: .label)
    
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
        
        headerView.addSubviewWithAnchors(selectModeButton, top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor)
        selectModeButton.addAction(UIAction(){ action in
            self.toggleSelectMode()
        }, for: .touchDown)
        
        let loadButton = UIButton().asIconButton("arrow.down.square", color: .black)
        headerView.addSubviewWithAnchors(loadButton, top: headerView.topAnchor, leading: selectModeButton.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        loadButton.addAction(UIAction(){ action in
            self.loadTrack()
        }, for: .touchDown)
    }
    
    @objc func loadTrack(){
        let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "gpx")!])
        filePicker.directoryURL = FileController.exportGpxDirURL
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
    
    func showTrackOnMap(track: TrackItem) {
        self.dismiss(animated: true){
            self.delegate?.showTrackOnMap(track: track)
        }
    }
    
}

extension TrackListViewController : TrackItemCellDelegate{
    
    func deleteTrackItem(item: TrackItem) {
        showDestructiveApprove(title: "confirmDeleteTrack".localize(), text: "deleteTrackHint".localize()){
            self.deleteTrack(track: item)
        }
    }
    
    func viewTrackItem(item: TrackItem) {
        let trackController = TrackViewController(track: item)
        trackController.track = item
        trackController.delegate = self
        trackController.modalPresentationStyle = .fullScreen
        self.present(trackController, animated: true)
    }
    
    func showItemOnMap(item: TrackItem) {
        delegate?.showTrackOnMap(track: item)
    }
    
    func exportTrack(track: TrackItem) {
        if let url = GPXCreator.createTemporaryFile(track: track){
            let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
            controller.directoryURL = FileController.exportGpxDirURL
            present(controller, animated: true) {
                FileController.logFileInfo()
            }
        }
    }
    
    func deleteTrack(track: TrackItem, approved: Bool) {
        
    }
    
    private func deleteTrack(track: TrackItem){
        self.delegate?.deleteTrack(track: track, approved: true)
        tracks?.remove(track)
        tableView.reloadData()
    }
    
    func toggleSelectMode(){
        if selectMode{
            selectModeButton.tintColor = .black
            selectMode = false
        }
        else{
            selectModeButton.tintColor = .systemBlue
            selectMode = true
        }
    }
    
}

extension TrackListViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if let trackpoints = GPXParser.parseFile(url: url){
                if trackpoints.count > 0{
                    let track = TrackItem()
                    for tp in trackpoints{
                        track.trackpoints.append(tp)
                    }
                    track.evaluateImportedTrackpoints()
                    let alertController = UIAlertController(title: "name".localize(), message: "nameOrDescriptionHint".localize(), preferredStyle: .alert)
                    alertController.addTextField()
                    alertController.addAction(UIAlertAction(title: "ok".localize(),style: .default) { action in
                        track.name = alertController.textFields![0].text ?? url.lastPathComponent
                        TrackPool.addTrack(track: track)
                        TrackPool.save()
                        self.tracks?.append(track)
                        self.tableView.reloadData()
                    })
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
}
