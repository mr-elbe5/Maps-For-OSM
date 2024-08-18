/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

extension FileManager{
    
    public static let documentsURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    public static let imagesURL : URL = FileManager.default.urls(for: .picturesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    public static let movieLibraryURL : URL = FileManager.default.urls(for: .moviesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    
    public func initializeAppDirs() {
        Log.info("document folder is \(FileManager.documentsURL.path())")
        Log.info("image folder is \(FileManager.imagesURL.path())")
        FileManager.mediaDirURL = FileManager.privateURL.appendingPathComponent("media")
        FileManager.tilesDirURL = FileManager.privateURL.appendingPathComponent("tiles")
        try! FileManager.default.createDirectory(at: FileManager.tilesDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.mediaDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
}
