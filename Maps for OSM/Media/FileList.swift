/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias FileList = Array<FileData>
    
extension FileList{
    
    mutating func remove(_ file: FileData){
        for idx in 0..<self.count{
            if self[idx] == file{
                FileController.deleteFile(url: file.fileURL)
                self.remove(at: idx)
                return
            }
        }
    }
    
    mutating func removeAllFiles(){
        for file in self{
            FileController.deleteFile(url: file.fileURL)
        }
        removeAll()
    }
    
}
