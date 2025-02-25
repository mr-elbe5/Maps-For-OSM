/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

protocol DownloadDelegate {
    func downloadSucceeded()
    func downloadWithError()
}

class TileDownloadOperation : AsyncOperation, @unchecked Sendable {
    
    var tile : MapTile
    var delegate : DownloadDelegate? = nil
    
    init(tile: MapTile) {
        self.tile = tile
        super.init()
    }
    
    override func startExecution(){
        //debug("TileDownloadOperation starting download of \(tile.shortDescription)")
        TileProvider.shared.loadTileImage(tile: tile, template: Preferences.shared.urlTemplate){ success in
            if success{
                DispatchQueue.main.async { [self] in
                    delegate?.downloadSucceeded()
                }
            }
            else{
                DispatchQueue.main.async { [self] in
                    Log.error("TileDownloadOperation loading \(tile.shortDescription)")
                    delegate?.downloadWithError()
                }
            }
            self.state = .isFinished
        }
    }
    
}

