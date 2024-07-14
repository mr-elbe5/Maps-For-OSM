/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5MapData

extension MainViewController{
    
    func openPreloadTiles() {
        let region = mapView.scrollView.tileRegion
        let controller = TilePreloadViewController()
        controller.mapRegion = region
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func changeTileSource() {
        let controller = TileSourceViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func deleteAllTiles(){
        showDestructiveApprove(title: "confirmDeleteTiles".localize(), text: "deleteTilesHint".localize()){
            TileProvider.shared.deleteAllTiles()
            self.mapView.clearTiles()
        }
    }
    
}
