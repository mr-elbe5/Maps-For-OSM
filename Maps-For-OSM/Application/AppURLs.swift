/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CommonBasics

class AppURLs {
    
    private static let tempDir = NSTemporaryDirectory()
    static var privateURL : URL = FileManager.default.urls(for: .applicationSupportDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
    static var documentURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var imageLibraryPath: String = NSSearchPathForDirectoriesInDomains(.picturesDirectory,.userDomainMask,true).first!
    static var imageLibraryURL : URL = FileManager.default.urls(for: .picturesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var mediaDirURL : URL = privateURL.appendingPathComponent("media")
    static var tilesDirURL : URL = privateURL.appendingPathComponent("tiles")
    static var exportGpxDirURL = documentURL.appendingPathComponent("gpx")
    static var exportMediaDirURL = documentURL.appendingPathComponent("media")
    static var backupDirURL = documentURL.appendingPathComponent("backup")
    
    static var temporaryPath : String {
        tempDir
    }
    
    static var temporaryURL : URL{
        URL(fileURLWithPath: temporaryPath, isDirectory: true)
    }
    
    static var privatePath : String{
        privateURL.path
    }
    
    static func initialize() {
        try! FileManager.default.createDirectory(at: privateURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: tilesDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: mediaDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: exportGpxDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: backupDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: exportMediaDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func deleteTemporaryFiles() -> Int{
        if !FileManager.default.fileExists(atPath: temporaryPath){
            return 0
        }
        return FileController.deleteAllFiles(dirURL: temporaryURL)
    }
    
    static func logFileInfo(){
        var names = FileController.listAllFiles(dirPath: temporaryPath)
        for name in names{
            print(name)
        }
        names = FileController.listAllFiles(dirPath: mediaDirURL.path)
        for name in names{
            print(name)
        }
    }
    
}
