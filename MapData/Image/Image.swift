/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import E5Data

open class Image : FileItem{
    
    public static var previewSize: CGFloat = 512
    
    public enum CodingKeys: String, CodingKey {
        case metaData
    }
    
    override public var type : LocatedItemType{
        .image
    }
    
    override public init(){
        super.init()
        fileName = "img_\(id).jpg"
    }
    
    public var metaData: ImageMetaData? = nil
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        metaData = try values.decodeIfPresent(ImageMetaData.self, forKey: .metaData)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metaData, forKey: .metaData)
        try super.encode(to: encoder)
    }
    
    public func readMetaData(){
        if let data = FileManager.default.readFile(url: fileURL){
            metaData = ImageMetaData()
            metaData?.readData(data: data)
        }
    }
    
    public func getPreviewFile() -> Data?{
        let url = FileManager.previewsDirURL.appendingPathComponent(fileName)
        return FileManager.default.readFile(url: url)
    }
    
    override public func prepareDelete(){
        super.prepareDelete()
        if FileManager.default.fileExists(dirPath: FileManager.previewsDirURL.path, fileName: fileName){
            if !FileManager.default.deleteFile(dirURL: FileManager.previewsDirURL, fileName: fileName){
                Log.error("FileItem could not delete preview: \(fileName)")
            }
        }
    }
    
#if os(macOS)
    public func getImage() -> NSImage?{
        if let data = getFile(){
            return NSImage(data: data)
        } else{
            return nil
        }
    }
    public func getPreview() -> NSImage?{
        if let data = getPreviewFile(){
            return NSImage(data: data)
        } else{
            return createPreview()
        }
    }
    public func createPreview() -> NSImage?{
        if let preview = PreviewCreator.createPreview(of: getImage()){
            let url = FileManager.previewsDirURL.appendingPathComponent(fileName)
            if let tiff = preview.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
                if let previewData = tiffData.representation(using: .jpeg, properties: [:]) {
                    if FileManager.default.assertDirectoryFor(url: url){
                        FileManager.default.saveFile(data: previewData, url: url)
                        return preview
                    }
                }
            }
            return preview
        }
        return nil
    }
#elseif os(iOS)
    public func getImage() -> UIImage?{
        if let data = getFile(){
            return UIImage(data: data)
        } else{
            return nil
        }
    }
    public func getPreview() -> UIImage?{
        if let data = getPreviewFile(){
            return UIImage(data: data)
        } else{
            return createPreview()
        }
    }
    public func createPreview() -> UIImage?{
        if let preview = PreviewCreator.createPreview(of: getImage()){
            let url = FileManager.previewsDirURL.appendingPathComponent(fileName)
            if let data = preview.jpegData(compressionQuality: 0.85){
                if !FileManager.default.saveFile(data: data, url: url){
                    Log.error("preview could not be saved at \(url)")
                }
            }
            return preview
        }
        return nil
    }
    public func saveImage(uiImage: UIImage){
        if let data = uiImage.jpegData(compressionQuality: 0.8){
            saveFile(data: data)
        }
    }
#endif
    
}

public typealias ImageList = Array<Image>

extension ImageList{
    
    public mutating func remove(_ image: Image){
        for idx in 0..<self.count{
            if self[idx].equals(image){
                self.remove(at: idx)
                return
            }
        }
    }
    
}


