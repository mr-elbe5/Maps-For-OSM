/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

extension FileManager {
    
    static var mediaDirURL : URL = privateURL.appendingPathComponent("media")
    static var tilesDirURL : URL = privateURL.appendingPathComponent("tiles")
    static var exportGpxDirURL = documentURL.appendingPathComponent("gpx")
    static var exportMediaDirURL = documentURL.appendingPathComponent("media")
    static var backupDirURL = documentURL.appendingPathComponent("backup")
    
    static func initializeAppDirs() {
        try! FileManager.default.createDirectory(at: tilesDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: mediaDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: exportGpxDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: backupDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: exportMediaDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func logFileInfo(){
        var names = listAllFiles(dirPath: FileManager.tempDir)
        for name in names{
            print(name)
        }
        names = listAllFiles(dirPath: FileManager.mediaDirURL.path)
        for name in names{
            print(name)
        }
    }
    
}
