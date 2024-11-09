/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class NavViewController: UIViewController {
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.setBackground(.systemBackground)
        setNavBarStyle()
        if let title = self.title{
            self.navigationItem.titleView = UILabel(text: title).withTextColor(navigationController?.navigationBar.tintColor ?? .label)
        }
        let guide = view.safeAreaLayoutGuide
        loadSubviews(guide: guide)
        updateNavigationItems()
    }
    
    func setNavBarStyle(){
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
    }
    
    func loadSubviews(guide: UILayoutGuide) {
    }
    
    func updateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            self.close()
        })
    }
    
    func close(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
