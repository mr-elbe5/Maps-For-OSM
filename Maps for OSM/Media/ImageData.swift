/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class ImageData : FileData{
    
    private var _fileName = ""
    
    override var type : FileType{
        .image
    }
    
    override var fileName : String {
        get{
            _fileName
        }
        set{
            _fileName = newValue
        }
    }
    
    func setFileNameFromURL(_ url: URL){
        var name = url.lastPathComponent
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
