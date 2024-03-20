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
        }
    }
    
    var delegate: VideoItemCellDelegate? = nil
    
    override func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        if let videoItem = videoItem{
            
            let videoView = VideoPlayerView()
            videoView.setRoundedBorders()
            cellBody.addSubviewWithAnchors(videoView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            videoView.url = videoItem.fileURL
            videoView.setAspectRatioConstraint()
            
            if !videoItem.title.isEmpty{
                let titleView = UILabel(text: videoItem.title)
                titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                cellBody.addSubviewWithAnchors(titleView, top: videoView.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor)
            }
            else{
                videoView.bottom(cellBody.bottomAnchor)
            }
            
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteVideoItem(item: videoItem)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewVideoItem(item: videoItem)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(viewButton, top: cellBody.topAnchor, trailing: deleteButton.leadingAnchor, insets: defaultInsets)
            
        }
    }
    
}


