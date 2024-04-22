/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TableSectionHeader : UIView{
    
    func setupView(title: String){
        let label = TableSectionHeaderLabel()
        label.text = title
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        addSubviewCentered(label, centerX: self.centerXAnchor, centerY: self.centerYAnchor)
    }
    
}

class TableSectionHeaderLabel: UILabel {
    
    override var intrinsicContentSize: CGSize{
        return getExtendedIntrinsicContentSize(originalSize: super.intrinsicContentSize)
    }
    
}
