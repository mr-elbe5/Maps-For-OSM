/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension FileManager{
    
    public static let documentURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    public static let imageLibraryURL : URL = FileManager.default.urls(for: .picturesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    
    public static var exportGpxDirURL = FileManager.documentURL.appendingPathComponent("gpx")
    public static var exportMediaDirURL = FileManager.documentURL.appendingPathComponent("media")
    public static var backupDirURL = FileManager.documentURL.appendingPathComponent("backup")
    
    public static func initializeAppDirs() {
        initializeTileDir()
        initializeMediaDirs()
        try! FileManager.default.createDirectory(at: exportGpxDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: backupDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: exportMediaDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
}
