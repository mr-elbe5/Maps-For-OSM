//
//  FileManager+Tiles.swift
//  Maps-For-OSM
//
//  Created by Michael Rönnau on 20.10.24.
//


/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

extension FileManager {
    
    public static var tileDirURL : URL = privateURL.appendingPathComponent("tiles")
    
    public static func initializeTileDir() {
        try! FileManager.default.createDirectory(at: FileManager.tileDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func logTileFiles(){
        print("tile files:")
        let names = listAllFiles(dirPath: FileManager.tileDirURL.path)
        for name in names{
            print(name)
        }
    }
    
}