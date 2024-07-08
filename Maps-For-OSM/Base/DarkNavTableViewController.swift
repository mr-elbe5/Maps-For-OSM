/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

open class DarkNavTableViewController: DarkNavViewController {
    
    public var subheaderView : UIView? = nil
    public var tableView = UITableView()
    
    override open func loadSubviews(guide: UILayoutGuide) {
        var topAnchor = guide.topAnchor
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
    
    open func createSubheaderView(){
        let subheaderView = UIView()
        subheaderView.backgroundColor = .white
        setupSubheaderView(subheaderView: subheaderView)
        self.subheaderView = subheaderView
    }
    
    open func setupSubheaderView(subheaderView: UIView){
    }
    
    public func setNeedsUpdate(){
        tableView.reloadData()
    }
    
}
