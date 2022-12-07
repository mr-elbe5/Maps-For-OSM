/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PopupTableViewController: UIViewController {
    
    var headerView = UIView()
    var tableView = UITableView()
    
    var closeButton = UIButton().asIconButton("xmark.circle", color: .white)
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemGray5
        let guide = view.safeAreaLayoutGuide
        
        let spacer = UIView()
        spacer.backgroundColor = .systemGray6
        view.addSubviewWithAnchors(spacer, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: guide.topAnchor, insets: .zero)
        
        view.addSubviewWithAnchors(headerView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, insets: defaultInsets)
        setupHeaderView()
        
        view.addSubviewWithAnchors(tableView, top: headerView.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
    }
    
    func setupHeaderView(){
        headerView.backgroundColor = .black
        if let title = title{
            let label = UILabel()
            label.text = title
            label.textColor = .white
            headerView.addSubviewWithAnchors(label, top: headerView.topAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
                .centerX(headerView.centerXAnchor)
        }
        
        let closeButton = UIButton().asIconButton("xmark.circle", color: .white)
        headerView.addSubviewWithAnchors(closeButton, top: headerView.topAnchor, trailing: headerView.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        closeButton.addTarget(self, action: #selector(close), for: .touchDown)
    }
    
    func setNeedsUpdate(){
        tableView.reloadData()
    }
    
    @objc func close(){
        self.dismiss(animated: true)
    }
    
}

