/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

//deprecated
class TrackPool{
    
    static var storeKey = "tracks"
    
    static var list = Array<TrackItem>()
    
    static func load(){
        if let list : Array<TrackItem> = DataController.shared.load(forKey: storeKey){
            TrackPool.list = list
        }
    }
    
    static func loadFromFile(url: URL){
        if let string = FileController.readTextFile(url: url),let data : Array<TrackItem> = Array<TrackItem>.fromJSON(encoded: string){
            list = data
        }
    }
    
    static func addTracksToPlaces(){
        if !list.isEmpty{
            Log.info("adding tracks to places")
            for track in list{
                if let coordinate = track .startCoordinate{
                    var place = AppData.shared.getPlace(coordinate: coordinate)
                    if place == nil{
                        place = AppData.shared.createPlace(coordinate: coordinate)
                    }
                    place!.addItem(item: track)
                }
            }
            AppData.shared.save()
            list.removeAll()
            DataController.shared.remove(forKey: storeKey)
            Log.info("track pool invalidated")
        }
        else{
            Log.debug("no tracks to add to places")
        }
    }
    
}
