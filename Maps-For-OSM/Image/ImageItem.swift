/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data

class ImageItem : FileItem{
    
    override var type : PlaceItemType{
        .image
    }
    
    override init(){
        super.init()
        fileName = "img_\(id).jpg"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func getImage() -> UIImage?{
        if let data = getFile(){
            return UIImage(data: data)
        } else{
            return nil
        }
    }
    
    func saveImage(uiImage: UIImage){
        if let data = uiImage.jpegData(compressionQuality: 0.8){
            saveFile(data: data)
        }
    }
    
}

protocol ImageDelegate{
    func viewImage(image: ImageItem)
}

typealias ImageList = Array<ImageItem>

extension ImageList{
    
    mutating func remove(_ image: ImageItem){
        for idx in 0..<self.count{
            if self[idx].equals(image){
                self.remove(at: idx)
                return
            }
        }
    }
    
}


