/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class AudioItemCell: PlaceItemCell{
    
    static let CELL_IDENT = "audioCell"
    
    var audioItem : AudioItem? = nil {
        didSet {
            updateCell()
            setSelected(audioItem?.selected ?? false, animated: false)
        }
    }
    
    var delegate: PlaceItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let item = audioItem{
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
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: lastAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
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


