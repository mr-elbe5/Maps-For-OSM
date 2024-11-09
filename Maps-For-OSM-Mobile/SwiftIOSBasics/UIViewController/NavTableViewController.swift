/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class NavTableViewController: NavViewController {
    
    var subheaderView : UIView? = nil
    var tableView = UITableView()
    
    override func loadSubviews(guide: UILayoutGuide) {
        var topAnchor = guide.topAnchor
        if let subheaderView = subheaderView{
            view.addSubviewWithAnchors(subheaderView, top: topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, insets: defaultInsets)
            topAnchor = subheaderView.bottomAnchor
        }
        tableView.backgroundColor = .systemBackground
        view.addSubviewWithAnchors(tableView, top: topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = .none
    }
    
    func createSubheaderView(){
        let subheaderView = UIView()
        setupSubheaderView(subheaderView: subheaderView)
        self.subheaderView = subheaderView
    }
    
    func setupSubheaderView(subheaderView: UIView){
        subheaderView.backgroundColor = .tertiarySystemBackground
        subheaderView.setRoundedEdges()
    }
    
    func setNeedsUpdate(){
        tableView.reloadData()
    }
    
}
