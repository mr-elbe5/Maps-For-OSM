/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

struct TileProvider{
    
    static let shared = TileProvider()
    
    static let maxTries: Int = 3
    
    func loadTileImage(tile: MapTile, result: @escaping (Bool) -> Void) {
        let request = URLRequest(url: tile.tileUrl, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        let task = getDownloadTask(request: request, tile: tile, tries: 1, result: result)
        DispatchQueue.global(qos: .userInitiated).async{
            task.resume()
        }
    }
    
    private func retryLoadTileImage(tile: MapTile, tries: Int, result: @escaping (Bool) -> Void) {
        let request = URLRequest(url: tile.tileUrl, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20.0)
        let task = getDownloadTask(request: request, tile: tile, tries: tries, result: result)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 5){
            task.resume()
        }
    }
    
    private func getDownloadTask(request: URLRequest, tile: MapTile, tries: Int, result: @escaping (Bool) -> Void) -> URLSessionDataTask{
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            var statusCode = 0
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if statusCode == 200, let data = data{
                if tries > 1{
                    print("got tile in try \(tries)")
                }
                DispatchQueue.global(qos: .background).async {
                    if !saveTile(fileUrl: tile.fileUrl, data: data){
                        print("could not save tile \(tile.string)")
                    }
                }
                tile.image = UIImage(data: data)
                result(true)
                return
            }
            if let error = error {
                print("error loading tile from \(tile.tileUrl.path), error: \(error.localizedDescription)")
            }
            else{
                print("error loading tile from \(tile.tileUrl.path), statusCode=\(statusCode)")
            }
            if tries <= TileProvider.maxTries{
                retryLoadTileImage(tile: tile, tries: tries + 1){ success in
                    result(success)
                }
            }
            
        }
    }
    
    private func saveTile(fileUrl: URL, data: Data?) -> Bool{
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
    
    func deleteAllTiles(){
        do{
            try FileManager.default.removeItem(at: AppState.tileDirectory)
            try FileManager.default.createDirectory(at: AppState.tileDirectory, withIntermediateDirectories: true)
            //print("tile directory deleted")
        }
        catch{
            print(error)
        }
    }
    
    func dumpTiles(){
        var paths = Array<String>()
        if let subpaths = FileManager.default.subpaths(atPath: AppState.tileDirectory.path){
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
