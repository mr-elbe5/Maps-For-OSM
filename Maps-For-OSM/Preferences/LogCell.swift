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

class LogCell: TableViewCell{
    
    static let CELL_IDENT = "logCell"
    
    var log = ""
    
    override func setupCellBody(){
        cellBody.addSubviewFilling(itemView, insets: .zero)
        cellBody.setBackground(.cellBackground)
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        let label = UILabel(text: log)
        itemView.addSubviewFilling(label, insets: smallInsets)
    }
    
}


