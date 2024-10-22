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
import E5Data

public protocol UploadDelegate {
    func uploadSucceeded()
    func uploadWithError()
}

open class TileUploadOperation : AsyncOperation, @unchecked Sendable {
    
    public var tile : MapTile
    public var data : Data
    public var delegate : UploadDelegate? = nil
    
    public init(tile: MapTile, data: Data) {
        self.tile = tile
        self.data = data
        super.init()
    }
    
    override public func startExecution(){
        Log.debug("TilUploadOperation starting upload of \(tile.shortDescription)")
        WatchConnector.shared.sendTile(tile, data: data){ success in
            if success{
                DispatchQueue.main.async { [self] in
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

