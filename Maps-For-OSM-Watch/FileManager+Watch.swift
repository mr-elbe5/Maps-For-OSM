//
//  FileManager+Watch.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 08.10.24.
//

import Foundation
import E5Data

extension FileManager {
    
    public static var tilesDirURL : URL = privateURL.appendingPathComponent("tiles")
    
    public static func initializeTilesDir() {
        try! FileManager.default.createDirectory(at: tilesDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
}

