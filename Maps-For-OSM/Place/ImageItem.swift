/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

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

extension Array<ImageItem>{
    
    mutating func remove(_ image: ImageItem){
        for idx in 0..<self.count{
            if self[idx] == image{
                self.remove(at: idx)
                return
            }
        }
    }
    
    var allSelected: Bool{
        get{
            for item in self{
                if !item.selected{
                    return false
                }
            }
            return true
        }
    }
    
    var allUnselected: Bool{
        get{
            for item in self{
                if item.selected{
                    return false
                }
            }
            return true
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
    mutating func sortByDate(){
        self.sort(by: { $0.creationDate < $1.creationDate})
    }
    
}


