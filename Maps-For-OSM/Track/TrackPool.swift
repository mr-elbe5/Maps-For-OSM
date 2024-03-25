/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

//deprecated
class TrackPool{
    
    static var storeKey = "tracks"
    
    static var list = TrackList()
    
    static func load(){
        if let list : TrackList = DataController.shared.load(forKey: storeKey){
            TrackPool.list = list
        }
    }
    
    static func loadFromFile(url: URL){
        if let string = FileController.readTextFile(url: url),let data : TrackList = TrackList.fromJSON(encoded: string){
            list = data
        }
    }
    
    static func addTracksToPlaces(){
        if !list.isEmpty{
            Log.info("adding tracks to places")
            for track in list{
                if let coordinate = track .startCoordinate{
                    let place = PlacePool.assertPlace(coordinate: coordinate)
                    place.addItem(item: track)
                }
            }
            PlacePool.save()
            list.removeAll()
            DataController.shared.remove(forKey: storeKey)
            Log.info("track pool invalidated")
        }
        else{
            Log.debug("no tracks to add to places")
        }
    }
    
}
