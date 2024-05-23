/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CommonBasics

class AudioCell: PlaceItemCell{
    
    static let CELL_IDENT = "audioCell"
    
    var audio : AudioItem? = nil {
        didSet {
            updateCell()
            setSelected(audio?.selected ?? false, animated: false)
        }
    }
    
    var placeDelegate: PlaceDelegate? = nil
    
    override func setupCellBody(){
        iconView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        dateTimeView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: smallInsets)
        dateTimeView.addSubviewFilling(timeLabel, insets: smallInsets)
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
        cellBody.addSubviewWithAnchors(itemView, top: iconView.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: .zero)
    }
    
    override func updateIconView(isEditing: Bool){
        iconView.removeAllSubviews()
        if let audio = audio{
            var lastAnchor = iconView.trailingAnchor
            if isEditing{
                let selectedButton = UIButton().asIconButton(audio.selected ? "checkmark.square" : "square", color: .label)
                selectedButton.addAction(UIAction(){ action in
                    audio.selected = !audio.selected
                    selectedButton.setImage(UIImage(systemName: audio.selected ? "checkmark.square" : "square"), for: .normal)
                }, for: .touchDown)
                iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, trailing: lastAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
                lastAnchor = selectedButton.leadingAnchor
            }
            
            let mapButton = UIButton().asIconButton("map", color: .label)
            mapButton.addAction(UIAction(){ action in
                self.placeDelegate?.showPlaceOnMap(place: audio.place)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(mapButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: lastAnchor, bottom: iconView.bottomAnchor, insets: iconInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool){
        timeLabel.text = audio?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool){
        itemView.removeAllSubviews()
        if let audio = audio{
            let audioView = AudioPlayerView()
            audioView.setupView()
            itemView.addSubviewWithAnchors(audioView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, insets: UIEdgeInsets(top: 1, left: defaultInset, bottom: 0, right: defaultInset))
            if isEditing{
                let titleField = UITextField()
                titleField.setDefaults()
                titleField.text = audio.title
                titleField.delegate = self
                itemView.addSubviewWithAnchors(titleField, top: audioView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor)
            }
            else{
                if !audio.title.isEmpty{
                    let titleView = UILabel(text: audio.title)
                    itemView.addSubviewWithAnchors(titleView, top: audioView.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: smallInsets)
                }
                else{
                    audioView.bottom(itemView.bottomAnchor, inset: -defaultInset)
                }
                audioView.url = audio.fileURL
                audioView.enablePlayer()
            }
        }
    }

}

extension AudioCell: UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextView) {
        if let audio = audio{
            audio.title = textField.text
        }
    }
    
}


