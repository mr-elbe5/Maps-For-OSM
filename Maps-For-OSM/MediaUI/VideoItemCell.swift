/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol VideoItemCellDelegate{
    func deleteVideoItem(item: VideoItem)
    func viewVideoItem(item: VideoItem)
}

class VideoItemCell: PlaceItemCell{
    
    static let CELL_IDENT = "videoCell"
    
    var videoItem : VideoItem? = nil {
        didSet {
            updateCell()
            setSelected(videoItem?.selected ?? false, animated: false)
        }
    }
    
    var delegate: VideoItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let videoItem = videoItem{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteVideoItem(item: videoItem)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: halfFlatInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewVideoItem(item: videoItem)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: deleteButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: halfFlatInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = videoItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let videoItem = videoItem{
            let videoView = VideoPlayerView()
            videoView.setRoundedBorders()
            itemView.addSubviewWithAnchors(videoView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            videoView.url = videoItem.fileURL
            videoView.setAspectRatioConstraint()
            
            if !videoItem.title.isEmpty{
                let titleView = UILabel(text: videoItem.title)
                titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                itemView.addSubviewWithAnchors(titleView, top: videoView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor)
            }
            else{
                videoView.bottom(itemView.bottomAnchor)
            }
        }
    }
    
}


