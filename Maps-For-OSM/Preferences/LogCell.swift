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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupCellBody(){
        cellBody.addSubviewFilling(itemView, insets: .zero)
        itemView.addSubviewFilling(label, insets: smallInsets)
    }
    
    func updateCell(log: String){
        label.text = log
    }
    
}


