/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

protocol VideoCellDelegate: LocationItemCellDelegate{
    func viewVideo(item: Video)
}

class VideoCell: LocationItemCell{
    
    static let CELL_IDENT = "videoCell"
    
    var video : Video? = nil {
        didSet {
            updateCell()
            setSelected(video?.selected ?? false, animated: false)
        }
    }
    
    var delegate: VideoCellDelegate? = nil
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let video = video{
            let selectedButton = UIButton().asIconButton(video.selected ? "checkmark.square" : "square", color: .darkGray)
            selectedButton.addAction(UIAction(){ action in
                video.selected = !video.selected
                selectedButton.setImage(UIImage(systemName: video.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
            let viewButton = UIButton().asIconButton("magnifyingglass", color: .darkGray)
            viewButton.addAction(UIAction(){ action in
                self.delegate?.viewVideo(item: video)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(viewButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: selectedButton.leadingAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
            
        }
    }
    
    override func updateTimeLabel(){
        timeLabel.text = video?.creationDate.dateTimeString()
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let video = video{
            let videoView = VideoPlayerView()
            videoView.setRoundedBorders()
            itemView.addSubviewWithAnchors(videoView, top: iconView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 2, left: 0, bottom: defaultInset, right: 0))
            videoView.url = video.fileURL
            videoView.setAspectRatioConstraint()
            
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

extension VideoCell: UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextView) {
        if let item = video{
            item.title = textField.text
        }
    }
    
}



