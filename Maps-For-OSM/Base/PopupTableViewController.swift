/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PopupTableViewController: PopupViewController {
    
    var subheaderView : UIView? = nil
    var tableView = UITableView()
    
    override func loadView() {
        super.loadView()
        let guide = view.safeAreaLayoutGuide
        var topAnchor = headerView?.bottomAnchor ?? guide.topAnchor
        if let subheaderView = subheaderView{
            view.addSubviewWithAnchors(subheaderView, top: topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, insets: .zero)
            topAnchor = subheaderView.bottomAnchor
        }
        view.addSubviewWithAnchors(tableView, top: topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
    }
    
    func createSubheaderView(){
        let subheaderView = UIView()
        setupSubheaderView(subheaderView: subheaderView)
        self.subheaderView = subheaderView
    }
    
    func setupSubheaderView(subheaderView: UIView){
    }
    
    func setNeedsUpdate(){
        tableView.reloadData()
    }
    
}

