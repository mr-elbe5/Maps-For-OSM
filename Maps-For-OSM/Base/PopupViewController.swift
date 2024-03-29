/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class PopupViewController: UIViewController {
    
    var headerView : UIView? = nil
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemGroupedBackground
        let guide = view.safeAreaLayoutGuide
        createHeaderView()
        if let headerView = headerView{
            view.addSubviewWithAnchors(headerView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor)
        }
    }
    
    func createHeaderView(){
        let headerView = UIView()
        setupHeaderView(headerView: headerView)
        self.headerView = headerView
    }
    
    func setupHeaderView(headerView: UIView){
        headerView.backgroundColor = .systemBackground
        if let title = title{
            let label = UILabel(header: title)
            headerView.addSubviewWithAnchors(label, top: headerView.topAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
                .centerX(headerView.centerXAnchor)
        }
        let closeButton = UIButton().asIconButton("xmark.circle", color: .label)
        headerView.addSubviewWithAnchors(closeButton, top: headerView.topAnchor, trailing: headerView.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        closeButton.addTarget(self, action: #selector(close), for: .touchDown)
    }
    
    @objc func close(){
        self.dismiss(animated: true)
    }
    
}
