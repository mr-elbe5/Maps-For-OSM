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
    
    override func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        
        if let audioItem = audioItem{
            let deleteButton = UIButton().asIconButton("trash", color: .systemRed)
            deleteButton.addAction(UIAction(){ action in
                self.delegate?.deleteAudioItem(item: audioItem)
            }, for: .touchDown)
            cellBody.addSubviewWithAnchors(deleteButton, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: defaultInsets)
            let audioView = AudioPlayerView()
            audioView.setupView()
            cellBody.addSubviewWithAnchors(audioView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, insets: UIEdgeInsets(top: 1, left: defaultInset, bottom: 0, right: defaultInset))
            
            if !audioItem.title.isEmpty{
                let titleView = UILabel(text: audioItem.title)
                titleView.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                cellBody.addSubviewWithAnchors(titleView, top: audioView.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: defaultInsets)
            }
            else{
                audioView.bottom(cellBody.bottomAnchor)
            }
            audioView.url = audioItem.fileURL
            audioView.enablePlayer()
        }
    }

}


