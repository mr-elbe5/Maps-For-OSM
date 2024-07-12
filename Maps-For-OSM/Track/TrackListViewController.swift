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

    var tracks: Array<Track>? = nil
    
    let selectAllButton = UIButton().asIconButton("checkmark.square", color: .label)
    let deleteButton = UIButton().asIconButton("trash.square", color: .systemRed)
    
    var locationDelegate: LocationCellDelegate? = nil
    
    var mainViewController: MainViewController?{
        navigationController?.rootViewController as? MainViewController
    }
    
    override open func loadView() {
        title = "trackList".localize()
        super.loadView()
        tracks?.sortByDate()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.CELL_IDENT)
    }
    
    override func updateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            self.tracks?.deselectAll()
            self.navigationController?.popViewController(animated: true)
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "tracks".localize(), image: UIImage(systemName: "checkmark.square"), primaryAction: UIAction(){ action in
            self.toggleSelectAll()
        }))
        items.append(UIBarButtonItem(title: "images".localize(), image: UIImage(systemName: "trash.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.deleteSelected()
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        navigationItem.trailingItemGroups = groups
        
    }
    
    func toggleSelectAll(){
        if var tracks = tracks{
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
    }
    
    func deleteSelected(){
        if let tracks = tracks{
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
                    self.tracks?.remove(track)
                    Log.debug("deleting track \(track.name)")
                }
                AppData.shared.save()
                self.locationDelegate?.locationsChanged()
                self.tableView.reloadData()
            }
        }
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
        tracks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.CELL_IDENT, for: indexPath) as! TrackCell
        let track = tracks?.reversed()[indexPath.row]
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

