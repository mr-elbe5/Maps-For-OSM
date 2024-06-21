/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI

class PlaceItemCell: TableViewCell{
    
    var dateTimeView = UIView()
    var timeLabel = UILabel(text: Date.localDate.dateTimeString())
    
    override func setupCellBody(){
        cellBody.addSubviewFilling(itemView, insets: .zero)
        iconView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        dateTimeView.setBackground(UIColor(white: 1.0, alpha: 0.3)).setRoundedEdges()
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: smallInsets)
        dateTimeView.addSubviewFilling(timeLabel, insets: smallInsets)
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
    }
    
    override func updateCell(isEditing: Bool = false){
        updateItemView(isEditing: isEditing)
        updateTimeLabel(isEditing: isEditing)
        updateIconView(isEditing: isEditing)
    }
    
    func updateTimeLabel(isEditing: Bool){
    }
    
}

