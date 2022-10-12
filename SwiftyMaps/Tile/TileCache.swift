/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

struct TileCache{
    
    static var tilesDirectory = "files"
    
    static var cartoDirectory = "carto"
    static var topoDirectory = "topo"
    
    static func tileUrl(tile: MapTile) -> URL?{
        URL(string: AppState.currentUrlTemplate.replacingOccurrences(of: "{z}", with: String(tile.zoom)).replacingOccurrences(of: "{x}", with: String(tile.x)).replacingOccurrences(of: "{y}", with: String(tile.y)))
    }
    
    static func loadTileImage(tile: MapTile, result: @escaping (Data?) -> Void) {
        //print("loading tile image \(tile.zoom)/\(tile.x)/\(tile.y)")
        guard let url = tileUrl(tile: tile) else {print("could not crate map url"); return}
        loadTileImage(url: url, result: result)
    }
    
    static func loadTileImage(url: URL, result: @escaping (Data?) -> Void) {
        //print("loading tile image \(url)")
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 300.0)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var statusCode = 0
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if let error = error {
                print("error loading tile from \(url.path), error: \(error.localizedDescription)")
                result(nil)
            } else if statusCode == 200{
                //print("tile image \(tile.zoom)/\(tile.x)/\(tile.y) loaded")
                result(data)
            }
            else{
                print("error loading tile from \(url.path), statusCode=\(statusCode)")
                result(nil)
            }
        }
        task.resume()
    }
    
    static func fileUrl(tile: MapTile) -> URL?{
        AppState.currentTileDirectory.appendingPathComponent("\(tile.zoom)/\(tile.x)/\(tile.y).png")
    }
    
    static func tileExists(tile: MapTile) -> Bool{
        if let url = fileUrl(tile: tile){
            return tileExists(url: url)
        }
        return false
    }
    
    static func tileExists(url: URL) -> Bool{
        FileManager.default.fileExists(atPath: url.path)
    }
    
    static func getTile(zoom: Int, x: Int, y: Int) -> MapTile{
        let tile = MapTile(zoom: zoom, x: x, y: y)
        if let fileUrl = fileUrl(tile: tile), tileExists(url: fileUrl), let fileData = FileManager.default.contents(atPath: fileUrl.path){
            //print("getting image from file \(shortPath(fileUrl))")
            tile.image = UIImage(data: fileData)
        }
        return tile
    }
    
    static func saveTile(tile: MapTile, data: Data?) -> Bool{
        if let fileUrl = fileUrl(tile: tile){
            return saveTile(fileUrl: fileUrl, data: data)
        }
        return false
    }
    
    static func saveTile(fileUrl: URL, data: Data?) -> Bool{
        if let data = data{
            let dirUrl = fileUrl.deletingLastPathComponent()
            var isDir:ObjCBool = true
            if !FileManager.default.fileExists(atPath: dirUrl.path, isDirectory: &isDir) {
                do{
                    try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true)
                }
                catch{
                    print("could not create directory")
                    return false
                }
            }
            do{
                try data.write(to: fileUrl, options: .atomic)
                //print("file saved to \(shortPath(url))")
                return true
            } catch let err{
                print("Error saving tile: " + err.localizedDescription)
                return false
            }
        }
        return false
    }
    
    static func shortPath(_ url: URL?) -> String{
        if let path : String = url?.path{
            if let idx = path.range(of: tilesDirectory, options: .backwards)?.lowerBound{
                return String(path[idx..<path.endIndex])
            }
        }
        return "...no tiles path"
    }
    
    static func clear(){
        do{
            try FileManager.default.removeItem(at: AppState.currentTileDirectory)
            //print("current tile directory deleted")
        }
        catch{
            print(error)
        }
    }
    
    static func dumpTiles(){
        var paths = Array<String>()
        if let subpaths = FileManager.default.subpaths(atPath: AppState.filesDirectory.path){
            for path in subpaths{
                /*if !path.hasSuffix(".png"){
                 continue
                 }*/
                paths.append(path)
            }
            paths.sort()
        }
        for path in paths{
            print(path)
        }
    }
    
}
