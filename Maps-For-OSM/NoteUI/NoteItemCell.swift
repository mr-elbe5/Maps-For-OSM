/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol NoteItemCellDelegate{
    func deleteNoteItem(item: NoteItem)
}

class NoteItemCell: PlaceItemCell{
    
    static let CELL_IDENT = "noteCell"
    
    var noteItem : NoteItem? = nil {
        didSet {
            updateCell()
        }
    }
    
    var delegate: NoteItemCellDelegate? = nil
    
    override func updateIconView(isEditing: Bool = false){
        iconView.removeAllSubviews()
        if let note = noteItem{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteNoteItem(item: note)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(deleteButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: iconView.trailingAnchor, bottom: iconView.bottomAnchor, insets: halfFlatInsets)
        }
    }
    
    override func updateTimeLabel(isEditing: Bool = false){
        timeLabel.text = noteItem?.creationDate.dateTimeString()
    }
    
    override func updateItemView(isEditing: Bool = false){
        itemView.removeAllSubviews()
        if let note = noteItem{
            let header = UILabel(header: "note".localize())
            itemView.addSubviewWithAnchors(header, top: itemView.topAnchor, insets: UIEdgeInsets(top: 40, left: defaultInset, bottom: defaultInset, right: defaultInset))
                .centerX(itemView.centerXAnchor)
            let noteLabel = UILabel(text: note.note)
            itemView.addSubviewWithAnchors(noteLabel, top: header.bottomAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: defaultInsets)
            
        }
    }
    
}


