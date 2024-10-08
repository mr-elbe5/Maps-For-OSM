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

public struct TileProvider{
    
    public static let shared = TileProvider()
    
    public static let maxTries: Int = 3
    
    public func loadTileImage(tile: MapTile, template: String, result: @escaping (Bool) -> Void) {
        let request = URLRequest(url: tile.tileUrl(template: template), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        let task = getDownloadTask(request: request, tile: tile, template: template, tries: 1, result: result)
        DispatchQueue.global(qos: .userInitiated).async{
            task.resume()
        }
    }
    
    private func retryLoadTileImage(tile: MapTile, template: String, tries: Int, result: @escaping (Bool) -> Void) {
        let request = URLRequest(url: tile.tileUrl(template: template), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20.0)
        let task = getDownloadTask(request: request, tile: tile, template: template, tries: tries, result: result)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 5){
            task.resume()
        }
    }
    
    private func getDownloadTask(request: URLRequest, tile: MapTile, template: String, tries: Int, result: @escaping (Bool) -> Void) -> URLSessionDataTask{
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            var statusCode = 0
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if statusCode == 200, let data = data{
                Log.debug("TileProvider loaded tile \(tile.shortDescription)")
                if tries > 1{
                    Log.info("TileProvider got tile in try \(tries)")
                }
                DispatchQueue.global(qos: .background).async {
                    if !saveTile(fileUrl: tile.fileUrl, data: data){
                        Log.error("TileProvider could not save tile \(tile.shortDescription)")
                    }
                }
                tile.imageData = data
                result(true)
                return
            }
            if let err = err {
                switch (err as? URLError)?.code {
                case .some(.timedOut):
                    Log.error("TileProvider timeout loading tile from \(tile.tileUrl(template: template).path), error: \(err.localizedDescription)")
                default:
                    Log.error("TileProvider loading tile from \(tile.tileUrl(template: template).path), error: \(err.localizedDescription)")
                }
            }
            else{
                Log.error("TileProvider loading tile from \(tile.tileUrl(template: template).path), statusCode=\(statusCode)")
            }
            if tries <= TileProvider.maxTries{
                retryLoadTileImage(tile: tile, template: template, tries: tries + 1){ success in
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
                catch let err{
                    Log.error("TileProvider could not create directory", error: err)
                    return false
                }
            }
            do{
                try data.write(to: fileUrl, options: .atomic)
                //debug("TileProvider file saved to \(fileUrl)")
                return true
            } catch let err{
                Log.error("TileProvider saving tile: " + err.localizedDescription)
                return false
            }
        }
        return false
    }
    
    public func deleteAllTiles(){
        do{
            try FileManager.default.removeItem(at: MapTile.tilesDirURL)
            try FileManager.default.createDirectory(at: MapTile.tilesDirURL, withIntermediateDirectories: true)
            //Log.debug("TileProvider tile directory cleared")
        }
        catch let err{
            Log.error("TileProvider", error: err)
        }
    }
    
    public func dumpTiles(){
        var paths = Array<String>()
        if let subpaths = FileManager.default.subpaths(atPath: MapTile.tilesDirURL.path){
            for path in subpaths{
                paths.append(path)
            }
            paths.sort()
        }
        for path in paths{
            print(path)
        }
    }
    
}
