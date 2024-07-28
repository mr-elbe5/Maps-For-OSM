/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension FileManager{
    
    public static let documentURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    public static let imageLibraryURL : URL = FileManager.default.urls(for: .picturesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    
    public func initializeAppDirs() {
        FileManager.mediaDirURL = FileManager.privateURL.appendingPathComponent("media")
        FileManager.tilesDirURL = FileManager.privateURL.appendingPathComponent("tiles")
        FileManager.exportGpxDirURL = FileManager.documentURL.appendingPathComponent("gpx")
        FileManager.exportMediaDirURL = FileManager.documentURL.appendingPathComponent("media")
        FileManager.backupDirURL = FileManager.documentURL.appendingPathComponent("backup")
        try! FileManager.default.createDirectory(at: FileManager.tilesDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.mediaDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.exportGpxDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.backupDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.exportMediaDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
}
