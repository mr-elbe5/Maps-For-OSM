/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class ImageFile : MediaFile{
    
    override var type : MediaType{
        .image
    }
    
    override init(){
        super.init()
        fileName = "img_\(id).jpg"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func setFileNameFromURL(_ url: URL){
        var name = url.lastPathComponent
        debug("file name from url is \(name)")
        fileName = name
        if fileExists(){
            info("cannot use file name \(fileName)")
            var count = 1
            var ext = ""
            if let pntPos = name.lastIndex(of: "."){
                ext = String(name[pntPos...])
                name = String(name[..<pntPos])
            }
            do{
                fileName = "\(name)(\(count))\(ext)"
                if !fileExists(){
                    info("new file name is \(fileName)")
                    return
                }
                count += 1
            }
        }
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
