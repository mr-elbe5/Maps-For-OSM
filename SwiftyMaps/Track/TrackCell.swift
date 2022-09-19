/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol TrackCellDelegate{
    func showTrackOnMap(track: Track)
    func viewTrackDetails(track: Track)
    func exportTrack(track: Track)
    func deleteTrack(track: Track, approved: Bool)
}

class TrackCell: UITableViewCell{
    
    var track : Track? = nil {
        didSet {
            updateCell()
        }
    }
    
    //TrackListViewController
    var delegate: TrackCellDelegate? = nil
    
    var cellBody = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        shouldIndentWhileEditing = false
        cellBody.backgroundColor = .white
        cellBody.layer.cornerRadius = 5
        contentView.addSubview(cellBody)
        cellBody.fillView(view: contentView, insets: defaultInsets)
        accessoryType = .none
        updateCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        if let track = track{
            let trackView = TrackListItemView(data: track)
            trackView.delegate = self
            cellBody.addSubview(trackView)
            trackView.fillView(view: cellBody)
            
        }
    }
    
}

extension TrackCell: TrackListItemDelegate{
    
    func viewTrack(sender: TrackListItemView) {
        self.delegate?.viewTrackDetails(track: sender.trackData)
    }
    
    func showTrackOnMap(sender: TrackListItemView) {
        self.delegate?.showTrackOnMap(track: sender.trackData)
    }
    
    func exportTrack(sender: TrackListItemView) {
        self.delegate?.exportTrack(track: sender.trackData)
    }
    
    func deleteTrack(sender: TrackListItemView) {
        self.delegate?.deleteTrack(track: sender.trackData, approved: false)
    }
    
}

