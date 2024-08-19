/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import E5Data

extension FileManager {
    
    public static var mediaDirURL : URL = privateURL.appendingPathComponent("media")
    public static var previewsDirURL : URL = privateURL.appendingPathComponent("previews")
    public static var tilesDirURL : URL = privateURL.appendingPathComponent("tiles")
    
    public func logFileInfo(){
        print("temp files:")
        var names = listAllFiles(dirPath: FileManager.default.temporaryDirectory.path)
        for name in names{
            print(name)
        }
        print("media files:")
        names = listAllFiles(dirPath: FileManager.mediaDirURL.path)
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
