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
    
    var label = UILabel(text: "")
    
    override func setupCellBody(){
        cellBody.addSubviewFilling(itemView, insets: .zero)
        cellBody.setBackground(.cellBackground)
        itemView.addSubviewFilling(label, insets: smallInsets)
    }
    
    func updateCell(log: String){
        label.text = log
    }
    
}


