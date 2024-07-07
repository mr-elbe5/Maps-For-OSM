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

class MapCameraViewController: CameraViewController {
    
    override public func loadView() {
        super.loadView()
        view.backgroundColor = .black
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
    }
    
}
