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
        if tile.imageData != nil{
            //print("Tile already present")
            return
        }
        //print("try loading file \(tile.fileUrl.lastPathComponent)")
        if FileManager.default.fileExists(url: tile.fileUrl), let data = FileManager.default.readFile(url: tile.fileUrl)    {
            tile.imageData = data
            //print("Tile loaded from file")
            return
        }
        Log.info("loading tile from phone")
        loadTileImage(tile: tile, tries: 1)
    }
    
    private func loadTileImage(tile: TileData, tries: Int) {
        PhoneConnector.instance.requestTile(tile){ success in
            if success, let imageData = tile.imageData{
                if FileManager.default.saveFile(data: imageData, url: tile.fileUrl){
                    //print("file \(tile.fileUrl.lastPathComponent) saved")
                }
                else{
                    Log.error("could not save file \(tile.fileUrl.lastPathComponent)")
                }
            }
            else if tries <= TileProvider.maxTries{
                Log.info("reloading tile from phone in try \(tries)")
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
        print("all tiles:")
        if let paths = FileManager.default.subpaths(atPath: FileManager.tilesDirURL.path){
            for path in paths{
                print(path)
            }
        }
    }
    
}
