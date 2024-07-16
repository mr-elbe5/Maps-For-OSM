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

class TrackListViewController: NavTableViewController{

    var tracks = Array<Track>()
    
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash.square", color: .systemRed)
    
    var locationDelegate: LocationCellDelegate? = nil
    
    var mainViewController: MainViewController?{
        navigationController?.rootViewController as? MainViewController
    }
    
    override open func loadView() {
        title = "trackList".localize()
        setupData()
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackListCell.self, forCellReuseIdentifier: TrackListCell.LIST_CELL_IDENT)
    }
    
    override func updateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            self.tracks.deselectAll()
            self.navigationController?.popViewController(animated: true)
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "importTrack".localize(), image: UIImage(systemName: "square.and.arrow.down"), primaryAction: UIAction(){ action in
            self.importTrack()
        }))
        items.append(UIBarButtonItem(title: "selectAll".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "deleteSelected".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        navigationItem.trailingItemGroups = groups
        
    }
    
    func setupData(){
        tracks.removeAll()
        tracks.append(contentsOf: AppData.shared.locations.tracks)
        tracks.sortByDate()
    }
    
    func toggleSelectAll(){
        if tracks.allSelected{
            tracks.deselectAll()
        }
        else{
            tracks.selectAll()
        }
        for cell in tableView.visibleCells{
            (cell as? TrackCell)?.updateIconView()
        }
    }
    
    func deleteSelected(){
        var list = Array<Track>()
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
                track.location.deleteItem(item: track)
                self.tracks.remove(track)
                Log.debug("deleting track \(track.name)")
            }
            AppData.shared.save()
            self.locationDelegate?.locationsChanged()
            self.tableView.reloadData()
        }
    }
    
    func importTrack(){
        let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "gpx")!])
        filePicker.directoryURL = FileManager.exportGpxDirURL
        filePicker.allowsMultipleSelection = false
        filePicker.delegate = self
        filePicker.modalPresentationStyle = .fullScreen
        self.present(filePicker, animated: true)
    }
    
    func exportTrack(item: Track) {
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
        tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackListCell.LIST_CELL_IDENT, for: indexPath) as! TrackListCell
        let track = tracks.reversed()[indexPath.row]
        cell.track = track
        cell.delegate = self
        cell.updateCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
  
extension TrackListViewController : TrackCellDelegate{
    
    func editTrack(track: Track) {
        let controller = TrackViewController(track: track)
        controller.track = track
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showTrackOnMap(track: Track) {
        navigationController?.popToRootViewController(animated: true)
        mainViewController?.showTrackOnMap(track: track)
    }
    
}

extension TrackListViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first{
            if url.pathExtension == "gpx"{
                importGPXFile(url: url)
            }
        }
    }
    
    private func importGPXFile(url: URL){
        if let gpxData = GPXParser.parseFile(url: url), !gpxData.isEmpty{
            let track = Track()
            track.name = gpxData.name
            for segment in gpxData.segments{
                for point in segment.points{
                    track.trackpoints.append(Trackpoint(location: point.location))
                }
            }
            track.evaluateImportedTrackpoints()
            if track.name.isEmpty{
                let ext = url.pathExtension
                var name = url.lastPathComponent
                name = String(name[name.startIndex...name.index(name.endIndex, offsetBy: -ext.count)])
                Log.debug(name)
                track.name = name
            }
            track.evaluateImportedTrackpoints()
            track.startTime = track.trackpoints.first?.timestamp ?? Date.localDate
            track.endTime = track.trackpoints.last?.timestamp ?? Date.localDate
            track.creationDate = track.startTime
            var newLocation = false
            var location = AppData.shared.getLocation(coordinate: track.startCoordinate!)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: track.startCoordinate!)
                newLocation = true
            }
            location!.addItem(item: track)
            AppData.shared.save()
            setupData()
            tableView.reloadData()
            DispatchQueue.main.async {
                if newLocation{
                    self.locationDelegate?.locationAdded(location: location!)
                }
                else{
                    self.locationDelegate?.locationChanged(location: location!)
                }
            }
        }
    }
    
}

