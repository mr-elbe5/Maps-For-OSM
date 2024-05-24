/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import CommonBasics

class AppData{
    
    static var storeKey = "locations"
    
    static var shared = AppData()
    
    var places = PlaceList()
    
    func resetCoordinateRegions() {
        for place in places{
            place.resetCoordinateRegion()
        }
    }
    
    func createPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = addPlace(coordinate: coordinate)
        return place
    }
    
    func addPlace(coordinate: CLLocationCoordinate2D) -> Place{
        let place = Place(coordinate: coordinate)
        places.append(place)
        return place
    }
    
    func deletePlace(_ place: Place){
        for idx in 0..<places.count{
            if places[idx].equals(place){
                place.deleteAllItems()
                places.remove(place)
                return
            }
        }
    }
    
    func deleteAllPlaces(){
        for idx in 0..<places.count{
            places[idx].deleteAllItems()
        }
        places.removeAll()
    }
    
    func getPlace(coordinate: CLLocationCoordinate2D) -> Place?{
        places.first(where:{
            $0.coordinateRegion.contains(coordinate: coordinate)
        })
    }
    
    func getPlace(id: UUID) -> Place?{
        places.first(where:{
            $0.id == id
        })
    }
    
    // local persistance
    
    func loadLocally(){
        if let list : PlaceList = UserDefaults.standard.load(forKey: AppData.storeKey){
            places = list
        }
        else{
            places = PlaceList()
        }
    }
    
    func saveLocally(){
        UserDefaults.standard.save(forKey: AppData.storeKey, value: places)
    }
    
    // file persistance
    
    func saveAsFile() -> URL?{
        let value = places.toJSON()
        let url = AppURLs.temporaryURL.appendingPathComponent(AppData.storeKey + ".json")
        if FileManager.default.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    func loadFromFile(url: URL){
        if let string = FileManager.default.readTextFile(url: url),let data : PlaceList = PlaceList.fromJSON(encoded: string){
            places = data
        }
    }
    
    func cleanupFiles(){
        let fileURLs = FileManager.default.listAllURLs(dirURL: AppURLs.mediaDirURL)
        var itemURLs = Array<URL>()
        var count = 0
        for item in places.fileItems{
            itemURLs.append(item.fileURL)
        }
        for url in fileURLs{
            if !itemURLs.contains(url){
                Log.debug("deleting local file \(url.lastPathComponent)")
                FileManager.default.deleteFile(url: url)
                count += 1
            }
        }
        if count > 0{
            Log.info("cleanup: deleted \(count) local unreferenced files")
        }
    }
    
    //deprecated
    func convertNotes(){
        var count = 0
        for place in places{
            if let note = place.note, !note.isEmpty{
                if !place.notes.contains(where: { noteItem in
                    noteItem.text == note
                })
                {
                    let noteItem = NoteItem()
                    noteItem.text = note
                    noteItem.creationDate = place.creationDate
                    place.addItem(item: noteItem)
                    place.note = ""
                    count += 1
                }
            }
        }
        if count > 0{
            Log.info("converted \(count) notes to note items")
        }
    }
    
}

