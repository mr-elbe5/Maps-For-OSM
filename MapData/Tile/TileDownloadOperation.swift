/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

public protocol DownloadDelegate {
    func downloadSucceeded()
    func downloadWithError()
}

open class TileDownloadOperation : AsyncOperation, @unchecked Sendable {
    
    public var tile : MapTile
    public var delegate : DownloadDelegate? = nil
    
    public init(tile: MapTile) {
        self.tile = tile
        super.init()
    }
    
    override public func startExecution(){
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

