/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5Data


protocol EditTrackListDelegate{
    func trackpointChangedInList(_ trackpoint: Trackpoint)
    func trackpointsChanged()
}

class EditTrackListView: MenuScrollView{
    
    var track: Track
    
    var selectAllButton: NSButton!
    var deleteSelectedButton: NSButton!
    var deleteTrackpointButton: NSButton!
    
    var delegate: EditTrackListDelegate? = nil
    
    init(track: Track){
        self.track = track
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupMenuView(){
        selectAllButton = NSButton(icon: "checkmark.square", color: .white, target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        menuView.addSubviewWithAnchors(selectAllButton, top: menuView.topAnchor, leading: menuView.leadingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        deleteSelectedButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteSelectedButton.toolTip = "deleteSelected".localize()
        menuView.addSubviewWithAnchors(deleteSelectedButton, top: menuView.topAnchor, leading: selectAllButton.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
    }
    
    override func setupContentView(){
        contentView.backgroundColor = .darkGray
        contentView.removeAllSubviews()
        var lastView: NSView? = nil
        for trackpoint in track.trackpoints{
            let cell = EditTrackListCell(trackpoint: trackpoint)
            cell.setupView()
            cell.delegate = self
            contentView.addSubviewWithAnchors(cell, top: lastView == nil ? contentView.topAnchor : lastView!.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: smallInsets)
            lastView = cell
        }
        lastView?.bottom(contentView.bottomAnchor)
    }

    func trackpointChangedInMap(_ trackpoint: Trackpoint) {
        for sv in contentView.subviews{
            if let cell = sv as? EditTrackListCell, cell.trackpoint.id == trackpoint.id{
                cell.updateIconView()
                return
            }
        }
    }
    
    func trackpointsChanged(){
        setupContentView()
    }
    
    @objc func toggleSelectAll(){
        if track.trackpoints.allSelected{
            track.trackpoints.deselectAll()
        }
        else{
            track.trackpoints.selectAll()
        }
        for sv in contentView.subviews{
            if let cell = sv as? EditTrackListCell{
                cell.updateIconView()
            }
        }
        delegate?.trackpointsChanged()
    }
    
    @objc func deleteSelected(){
        var list = TrackpointList()
        for i in 0..<track.trackpoints.count{
            let tp = track.trackpoints[i]
            if tp.selected{
                list.append(tp)
            }
        }
        if list.isEmpty{
            return
        }
        print("deleting \(list.count) trackpoints")
        track.trackpoints.removeAll(where: { tp in
            list.contains(where: { tp1 in
                return tp.id == tp1.id
            })
        })
        track.trackpointsChanged()
        self.setupContentView()
        delegate?.trackpointsChanged()
    }
    
}

extension EditTrackListView: EditTrackCellDelegate{
    
    func trackpointChanged(_ trackpoint: Trackpoint) {
        delegate?.trackpointChangedInList(trackpoint)
    }
    
}

