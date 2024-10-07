/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI
import E5Data

public struct TileProvider{
    
    static let instance = TileProvider()
    
    static let maxTries: Int = 3
    
    func assertTileImage(tile: TileData) {
        if tile.image != nil{
            print("Tile already loaded")
            return
        }
        if FileManager.default.fileExists(url: tile.fileUrl), let data = FileManager.default.readFile(url: tile.fileUrl)    {
            tile.image = UIImage(data: data)
            print("Tile loaded")
            return
        }
        print("loading tile")
        loadTileImage(tile: tile, tries: 1)
    }
    
    private func loadTileImage(tile: TileData, tries: Int) {
        PhoneConnector.instance.requestTile(tile){ success in
            if success, let image = tile.image{
                FileManager.default.createFile(atPath: tile.fileUrl.path(), contents: image.pngData())
            }
            else if tries <= TileProvider.maxTries{
                print("reloading tile in try \(tries)")
                loadTileImage(tile: tile, tries: tries + 1)
            }
        }
    }
    
    public func deleteAllTiles(){
        do{
            try FileManager.default.removeItem(at: FileManager.tilesDirURL)
        }
        catch let err{
            Log.error("TileProvider", error: err)
        }
    }
    
    public func dumpTiles(){
        var paths = Array<String>()
        if let paths = FileManager.default.subpaths(atPath: FileManager.tilesDirURL.path){
            for path in paths{
                print(path)
            }
        }
    }
    
}
