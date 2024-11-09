//
//  DownloadDelegate.swift
//  Maps-For-OSM
//
//  Created by Michael Rönnau on 22.10.24.
//


/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

protocol UploadDelegate {
    func uploadSucceeded()
    func uploadWithError()
}

class TileUploadOperation : AsyncOperation, @unchecked Sendable {
    
    var tile : MapTile
    var data : Data
    var delegate : UploadDelegate? = nil
    
    init(tile: MapTile, data: Data) {
        self.tile = tile
        self.data = data
        super.init()
    }
    
    override func startExecution(){
        Log.debug("TileUploadOperation starting upload of \(tile.shortDescription)")
        WatchConnector.shared.sendTile(tile, data: data){ success in
            if success{
                DispatchQueue.main.async { [self] in
                    Log.error("TileUploadOperation succeeded")
                    delegate?.uploadSucceeded()
                }
            }
            else{
                DispatchQueue.main.async { [self] in
                    Log.error("TileUploadOperation uploading \(tile.shortDescription)")
                    delegate?.uploadWithError()
                }
            }
            self.state = .isFinished
        }
    }
    
}

