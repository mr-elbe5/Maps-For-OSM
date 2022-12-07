/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

typealias PhotoList = Array<PhotoData>
    
extension PhotoList{
    
    mutating func remove(_ photo: PhotoData){
        for idx in 0..<self.count{
            if self[idx] == photo{
                FileController.deleteFile(url: photo.fileURL)
                self.remove(at: idx)
                return
            }
        }
    }
    
    mutating func removeAllPhotos(){
        for photo in self{
            FileController.deleteFile(url: photo.fileURL)
        }
        removeAll()
    }
    
}
