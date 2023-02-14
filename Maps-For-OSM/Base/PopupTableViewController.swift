/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PopupTableViewController: PopupViewController {
    
    var tableView = UITableView()
    
    override func loadView() {
        super.loadView()
        let guide = view.safeAreaLayoutGuide
        
        view.addSubviewWithAnchors(tableView, top: headerView?.bottomAnchor ?? guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
    }
    
    func setNeedsUpdate(){
        tableView.reloadData()
    }
    
}

