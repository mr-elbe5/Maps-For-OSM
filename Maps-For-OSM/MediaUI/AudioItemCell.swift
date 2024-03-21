/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol AudioItemCellDelegate{
    func deleteAudioItem(item: AudioItem)
}

class AudioItemCell: PlaceItemCell{
    
    static let CELL_IDENT = "audioCell"
    
    var audioItem : AudioItem? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: AudioItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let audioItem = audioItem{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteAudioItem(item: audioItem)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: halfFlatInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = audioItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let audioItem = audioItem{
            let audioView = AudioPlayerView()
            audioView.setupView()
            itemView.addSubviewWithAnchors(audioView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 1, left: defaultInset, bottom: 0, right: defaultInset))
            
            if !audioItem.title.isEmpty{
                let titleView = UILabel(text: audioItem.title)
                titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                itemView.addSubviewWithAnchors(titleView, top: audioView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: defaultInsets)
            }
            else{
                audioView.bottom(itemView.bottomAnchor)
            }
            audioView.url = audioItem.fileURL
            audioView.enablePlayer()
        }
    }

}


