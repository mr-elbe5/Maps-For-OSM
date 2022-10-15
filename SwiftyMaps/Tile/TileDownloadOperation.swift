/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

protocol DownloadDelegate {
    func downloadSucceeded()
    func downloadWithError()
}

class TileDownloadOperation : AsyncOperation {
    
    var tile : MapTile
    var delegate : DownloadDelegate? = nil
    
    init(tile: MapTile) {
        self.tile = tile
        super.init()
    }
    
    override func startExecution(){
        //print("starting \(tile.id)")
        guard let sourceUrl = TileCache.tileUrl(tile: tile) else {print("could not create map source url"); return}
        guard let targetUrl = TileCache.fileUrl(tile: tile) else {print("could not create map target url"); return}
        TileCache.loadTileImage(url: sourceUrl){ data in
            if let data = data, TileCache.saveTile(fileUrl: targetUrl, data: data){
                DispatchQueue.main.async { [self] in
                    delegate?.downloadSucceeded()
                }
            }
            else{
                DispatchQueue.main.async { [self] in
                    print("error on loading \(tile.string)")
                    delegate?.downloadWithError()
                }
            }
            self.state = .isFinished
        }
    }
    
}

