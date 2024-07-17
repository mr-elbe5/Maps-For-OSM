/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData

protocol LocationItemCellDelegate{
    func locationChanged(location: Location)
    func showLocationOnMap(coordinate: CLLocationCoordinate2D)
    
}

class LocationItemCell: TableViewCell{
    
    var dateTimeView = UIView()
    var timeLabel = UILabel(text: Date.localDate.dateTimeString())
    
    override func setupCellBody(){
        cellBody.addSubviewFilling(itemView, insets: .zero)
        cellBody.setBackground(.cellBackground).setRoundedBorders()
        iconView.setBackground(.iconViewColor).setRoundedEdges()
        dateTimeView.setBackground(.iconViewColor).setRoundedEdges()
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: smallInsets)
        dateTimeView.addSubviewFilling(timeLabel, insets: smallInsets)
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: smallInsets)
    }
    
    override func updateCell(){
        updateItemView()
        updateTimeLabel()
        updateIconView()
    }
    
    func updateTimeLabel(){
    }
    
}


