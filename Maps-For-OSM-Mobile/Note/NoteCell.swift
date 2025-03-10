/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class NoteCell: LocationItemCell{
    
    static let CELL_IDENT = "noteCell"
    
    var note : NoteItem? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: LocationItemCellDelegate? = nil
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let note = note{
            let selectedButton = UIButton().asIconButton(note.selected ? "checkmark.square" : "square", color: .label)
            selectedButton.addAction(UIAction(){ action in
                note.selected = !note.selected
                selectedButton.setImage(UIImage(systemName: note.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
        }
    }
    
    override func updateTimeLabel(){
        timeLabel.text = note?.creationDate.dateTimeString()
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let note = note{
            let header = UILabel(header: "note".localize())
            itemView.addSubviewWithAnchors(header, top: itemView.topAnchor, insets: UIEdgeInsets(top: 40, left: defaultInset, bottom: defaultInset, right: defaultInset))
                .centerX(itemView.centerXAnchor)
            let noteLabel = UILabel(text: note.text)
            itemView.addSubviewWithAnchors(noteLabel, top: header.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: defaultInsets)
        }
    }
    
}

extension NoteCell: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if let note = note{
            note.text = textView.text
        }
    }
    
}


