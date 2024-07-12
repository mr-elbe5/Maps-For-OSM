/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import AVFoundation
import CoreLocation
import Photos
import E5Data
import E5IOSAV
import E5IOSUI

class CameraViewController: E5CameraViewController {
    
    override public func loadView() {
        super.loadView()
        view.backgroundColor = .background
        bodyView.backgroundColor = .background
        navigationController?.navigationBar.barStyle = .current
        navigationController?.navigationBar.backgroundColor = .navbarBackground
        navigationController?.navigationBar.tintColor = .navbarTint
        updateNavigationItems()
    }
    
    public func updateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), primaryAction: UIAction(){ action in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
}
