/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

open class ViewController: UIViewController {
    
    override open func loadView() {
        super.loadView()
        view.backgroundColor = .black
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        let guide = view.safeAreaLayoutGuide
        loadSubviews(guide: guide)
        updateNavigationItems()
    }
    
    open func loadSubviews(guide: UILayoutGuide) {
    }
    
    open func updateNavigationItems() {
    }
    
    
}
