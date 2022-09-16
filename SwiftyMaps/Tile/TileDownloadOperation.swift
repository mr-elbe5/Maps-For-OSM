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
    var urlTemplate : String
    
    var delegate : DownloadDelegate? = nil
    
    init(tile: MapTile, urlTemplate: String) {
        self.tile = tile
        self.urlTemplate = urlTemplate
        super.init()
    }
    
    override func startExecution(){
        //print("starting \(tile.id)")
        guard let sourceUrl = MapTiles.tileUrl(tile: tile, urlTemplate: urlTemplate) else {print("could not create map source url"); return}
        guard let targetUrl = MapTiles.fileUrl(tile: tile) else {print("could not create map target url"); return}
        MapTiles.loadTileImage(url: sourceUrl){ data in
            if let data = data, MapTiles.saveTile(fileUrl: targetUrl, data: data){
                DispatchQueue.main.async { [self] in
                    //print("got \(tile.id)")
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

