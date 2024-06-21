/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

public protocol VideoDelegate{
    func viewVideoItem(item: VideoItem)
}

class VideoCell: PlaceItemCell{
    
    static let CELL_IDENT = "videoCell"
    
    var video : VideoItem? = nil {
        didSet {
            updateCell()
            setSelected(video?.selected ?? false, animated: false)
        }
    }
    
    var placeDelegate: PlaceDelegate? = nil
    var videoDelegate: VideoDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let video = video{
            var lastAnchor = iconView.trailingAnchor
            if isEditing{
                let selectedButton = UIButton().asIconButton(video.selected ? "checkmark.square" : "square", color: .label)
                selectedButton.addAction(UIAction(){ action in
                    video.selected = !video.selected
                    selectedButton.setImage(UIImage(systemName: video.selected ? "checkmark.square" : "square"), for: .normal)
                }, for: .touchDown)
                iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: lastAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
                lastAnchor = selectedButton.leadingAnchor
            }
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.placeDelegate?.showPlaceOnMap(place: video.place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, trailing: lastAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .label)
            viewButton.addAction(UIAction(){ action in
                self.videoDelegate?.viewVideoItem(item: video)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: mapButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = video?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let video = video{
            let videoView = VideoPlayerView()
            videoView.setRoundedBorders()
            itemView.addSubviewWithAnchors(videoView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            videoView.url = video.fileURL
            videoView.setAspectRatioConstraint()
            
            if isEditing{
                let titleField = UITextField()
                titleField.setDefaults()
                titleField.text = video.title
                titleField.delegate = self
                itemView.addSubviewWithAnchors(titleField, top: videoView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor)
            }
            else{
                if !video.title.isEmpty{
                    let titleView = UILabel(text: video.title)
                    itemView.addSubviewWithAnchors(titleView, top: videoView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: smallInsets)
                }
                else{
                    videoView.bottom(itemView.bottomAnchor)
                }
            }
        }
    }
    
}

extension VideoCell: UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextView) {
        if let item = video{
            item.title = textField.text
        }
    }
    
}



