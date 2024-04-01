/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol VideoItemCellDelegate: PlaceDelegate{
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
        if let item = videoItem{
            var lastAnchor = iconView.trailingAnchor
            if isEditing{
                let selectedButton = UIButton().asIconButton(item.selected ? "checkmark.square" : "square", color: .label)
                selectedButton.addAction(UIAction(){ action in
                    item.selected = !item.selected
                    selectedButton.setImage(UIImage(systemName: item.selected ? "checkmark.square" : "square"), for: .normal)
                }, for: .touchDown)
                iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: lastAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
                lastAnchor = selectedButton.leadingAnchor
            }
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.delegate?.showPlaceOnMap(place: item.place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: lastAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewVideoItem(item: item)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = videoItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let item = videoItem{
            let videoView = VideoPlayerView()
            videoView.setRoundedBorders()
            itemView.addSubviewWithAnchors(videoView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            videoView.url = item.fileURL
            videoView.setAspectRatioConstraint()
            
            if isEditing{
                let titleField = UITextField()
                titleField.setDefaults()
                titleField.text = item.title
                titleField.delegate = self
                itemView.addSubviewWithAnchors(titleField, top: videoView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor)
            }
            else{
                if !item.title.isEmpty{
                    let titleView = UILabel(text: item.title)
                    itemView.addSubviewWithAnchors(titleView, top: videoView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: smallInsets)
                }
                else{
                    videoView.bottom(itemView.bottomAnchor)
                }
            }
        }
    }
    
}

extension VideoItemCell: UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextView) {
        if let item = videoItem{
            item.title = textField.text
        }
    }
    
}



