/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation

class GPXParser : XMLParser{
    
    static func parseFile(url: URL) -> GPXData?{
        if let data = FileController.readFile(url: url){
            let parser = GPXParser(data: data)
            guard parser.parse() else { return nil }
            return parser.data
        }
        return nil
    }
    
    override init(data: Data){
        super.init(data: data)
        delegate = self
    }
    
    var data = GPXData()
    
    private var name: String? = nil
    private var currentElement : String? = nil
    
}

extension GPXParser : XMLParserDelegate{
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "name"{
            if data.name.isEmpty{
                name = ""
            }
        }
        else if elementName == "trkseg"{
            data.segments.append(GPXSegment())
        }
        else if elementName == "trkpt" || elementName == "wpt", let segment = data.segments.last{
            guard let latString = attributeDict["lat"], let lonString = attributeDict["lon"] else { return }
            guard let lat = Double(latString), let lon = Double(lonString) else { return }
            guard let latDegrees = CLLocationDegrees(exactly: lat), let lonDegrees = CLLocationDegrees(exactly: lon) else { return }
            
            let point = GPXPoint(coordinate: CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees))
            segment.points.append(point)
        }
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement{
        case "name":
            if !string.isEmpty{
                name? += string
            }
        case "time":
            if let point = data.segments.last?.points.last{
                point.time = string.ISO8601Date()
            }
        case "ele":
            if let point = data.segments.last?.points.last{
                point.altitude = CLLocationDistance(string) ?? 0
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name"{
            if let name = name{
                data.name = name
                self.name = nil
            }
        }
    }
    
}
