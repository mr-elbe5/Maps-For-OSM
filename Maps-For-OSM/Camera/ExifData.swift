/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class ExifData: NSObject {
    var colorModel: String?
    var pixelWidth: Double?
    var pixelHeight: Double?
    var dpiWidth: Int?
    var dpiHeight: Int?
    var depth: Int?
    var orientation: Int?
    var apertureValue: String?
    var brightnessValue: String?
    var dateTimeDigitized: String?
    var dateTimeOriginal: String?
    var offsetTime: String?
    var offsetTimeDigitized: String?
    var offsetTimeOriginal: String?
    var model: String?
    var software: String?
    var tileLength: Double?
    var tileWidth: Double?
    var xResolution: Double?
    var yResolution: Double?
    var altitude: String?
    var destBearing: String?
    var hPositioningError: String?
    var imgDirection: String?
    var latitude: String?
    var longitude: String?
    var speed: Double?
    
    private var dictionary: [String: Any] {
        return [
            "colorModel": colorModel as Any,
            "pixelWidth": pixelWidth as Any,
            "pixelHeight": pixelHeight as Any,
            "dpiWidth": dpiWidth as Any,
            "dpiHeight": dpiHeight as Any,
            "depth": depth as Any,
            "orientation": orientation as Any,
            "apertureValue": apertureValue as Any,
            "brightnessValue": brightnessValue as Any,
            "dateTimeDigitized": dateTimeDigitized as Any,
            "dateTimeOriginal": dateTimeOriginal as Any,
            "offsetTime": offsetTime as Any,
            "offsetTimeDigitized": offsetTimeDigitized as Any,
            "offsetTimeOriginal": offsetTimeOriginal as Any,
            "model": model as Any,
            "software": software as Any,
            "tileLength": tileLength as Any,
            "tileWidth": tileWidth as Any,
            "xResolution": xResolution as Any,
            "yResolution": yResolution as Any,
            "altitude": altitude as Any,
            "destBearing": destBearing as Any,
            "hPositioningError": hPositioningError as Any,
            "imgDirection": imgDirection as Any,
            "latitude": latitude as Any,
            "longitude": longitude as Any,
            "speed": speed as Any
        ]
    }
    
    public var toDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    init(data: Data) {
        super.init()
        self.setExifData(data: data as CFData)
    }
    
    init(url: URL) {
        super.init()
        if let data = NSData(contentsOf: url) {
            self.setExifData(data: data)
        }
    }
    
    init(image: UIImage) {
        super.init()
        if let data = image.cgImage?.dataProvider?.data {
            self.setExifData(data: data)
        }
    }
    
    func setExifData(data: CFData) {
        let options = [kCGImageSourceShouldCache as String: kCFBooleanFalse]
        
        if let imgSrc = CGImageSourceCreateWithData(data, options as CFDictionary) {
            if let metadata: NSDictionary = CGImageSourceCopyPropertiesAtIndex(imgSrc, 0, options as CFDictionary){
                self.colorModel = metadata[kCGImagePropertyColorModel] as? String
                self.pixelWidth = metadata[kCGImagePropertyPixelWidth] as? Double
                self.pixelHeight = metadata[kCGImagePropertyPixelHeight] as? Double
                self.dpiWidth = metadata[kCGImagePropertyDPIWidth] as? Int
                self.dpiHeight = metadata[kCGImagePropertyDPIHeight] as? Int
                self.depth = metadata[kCGImagePropertyDepth] as? Int
                self.orientation = metadata[kCGImagePropertyOrientation] as? Int
                
                if let tiffData = metadata[kCGImagePropertyTIFFDictionary] as? NSDictionary {
                    self.model = tiffData[kCGImagePropertyTIFFModel] as? String
                    self.software = tiffData[kCGImagePropertyTIFFSoftware] as? String
                    self.tileLength = tiffData[kCGImagePropertyTIFFTileLength] as? Double
                    self.tileWidth = tiffData[kCGImagePropertyTIFFTileWidth] as? Double
                    self.xResolution = tiffData[kCGImagePropertyTIFFXResolution] as? Double
                    self.yResolution = tiffData[kCGImagePropertyTIFFYResolution] as? Double
                }
                
                if let exifData = metadata[kCGImagePropertyExifDictionary] as? NSDictionary {
                    self.apertureValue = exifData[kCGImagePropertyExifApertureValue] as? String
                    self.brightnessValue = exifData[kCGImagePropertyExifBrightnessValue] as? String
                    self.dateTimeDigitized = exifData[kCGImagePropertyExifDateTimeDigitized] as? String
                    self.dateTimeOriginal = exifData[kCGImagePropertyExifDateTimeOriginal] as? String
                    if #available(iOS 13.0, *) {
                        self.offsetTime = exifData[kCGImagePropertyExifOffsetTime] as? String
                        self.offsetTimeDigitized = exifData[kCGImagePropertyExifOffsetTimeDigitized] as? String
                        self.offsetTimeOriginal = exifData[kCGImagePropertyExifOffsetTimeOriginal] as? String
                    }
                }
                
                if let gpsData = metadata[kCGImagePropertyGPSDictionary] as? NSDictionary {
                    self.altitude = gpsData[kCGImagePropertyGPSAltitude] as? String
                    self.destBearing = gpsData[kCGImagePropertyGPSDestBearing] as? String
                    self.hPositioningError = gpsData[kCGImagePropertyGPSHPositioningError] as? String
                    self.imgDirection = gpsData[kCGImagePropertyGPSImgDirection] as? String
                    self.latitude = gpsData[kCGImagePropertyGPSLatitude] as? String
                    self.longitude = gpsData[kCGImagePropertyGPSLongitude] as? String
                    self.speed = gpsData[kCGImagePropertyGPSSpeed] as? Double
                }
            }
        }
    }
}
