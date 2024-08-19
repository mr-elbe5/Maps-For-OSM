/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import E5Data

open class AppData{
    
    public static var storeKey = "locations"
    
    public static var shared = AppData()
    
    public var locations = LocationList()
    
    public func resetCoordinateRegions() {
        for location in locations{
            location.resetCoordinateRegion()
        }
    }
    
    public func createLocation(coordinate: CLLocationCoordinate2D) -> Location{
        let location = addLocation(coordinate: coordinate)
        return location
    }
    
    public func addLocation(coordinate: CLLocationCoordinate2D) -> Location{
        let location = Location(coordinate: coordinate)
        locations.append(location)
        return location
    }
    
    public func deleteLocation(_ location: Location){
        for idx in 0..<locations.count{
            if locations[idx].equals(location){
                location.deleteAllItems()
                locations.remove(location)
                return
            }
        }
    }
    
    public func deleteAllLocations(){
        for idx in 0..<locations.count{
            locations[idx].deleteAllItems()
        }
        locations.removeAll()
    }
    
    public func getLocation(coordinate: CLLocationCoordinate2D) -> Location?{
        locations.first(where:{
            $0.coordinateRegion.contains(coordinate: coordinate)
        })
    }
    
    public func getLocation(id: UUID) -> Location?{
        locations.first(where:{
            $0.id == id
        })
    }
    
    // local persistance
    
    open func load(){
        if let list : LocationList = UserDefaults.standard.load(forKey: AppData.storeKey){
            locations = list
        }
        else{
            locations = LocationList()
        }
    }
    
    open func save(){
        UserDefaults.standard.save(forKey: AppData.storeKey, value: locations)
    }
    
    // file persistance
    
    open func saveAsFile() -> URL?{
        let value = locations.toJSON()
        let url = FileManager.tempURL.appendingPathComponent(AppData.storeKey + ".json")
        if FileManager.default.saveFile(text: value, url: url){
            return url
        }
        return nil
    }
    
    open func loadFromFile(url: URL){
        if let string = FileManager.default.readTextFile(url: url),let data : LocationList = LocationList.fromJSON(encoded: string){
            locations = data
        }
    }
    
    open func cleanupFiles(){
        let fileURLs = FileManager.default.listAllURLs(dirURL: FileManager.mediaDirURL)
        var itemURLs = Array<URL>()
        var count = 0
        for item in locations.fileItems{
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
    
}

