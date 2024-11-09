/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension FileManager {
    
    static var mediaDirURL : URL = privateURL.appendingPathComponent("media")
    static var previewsDirURL : URL = privateURL.appendingPathComponent("previews")
    
    static func initializeMediaDirs() {
        try! FileManager.default.createDirectory(at: FileManager.mediaDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileManager.previewsDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func logMediaFiles(){
        print("media files:")
        var names = listAllFiles(dirPath: FileManager.mediaDirURL.path)
        for name in names{
            print(name)
        }
        print("preview files:")
        names = listAllFiles(dirPath: FileManager.previewsDirURL.path)
        for name in names{
            print(name)
        }
    }
    
}
