/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

typealias LocationList = Array<Location>

extension LocationList{
    
    mutating func remove(_ location: Location){
        removeAll(where: {
            $0.equals(location)
        })
    }
    
    mutating func removeLocations(of list: LocationList){
        for location in list{
            remove(location)
        }
    }
    
    mutating func sortAll(){
        self.sort()
        for location in self{
            location.sortItems()
        }
    }
    
    var tracks: Array<TrackItem>{
        get{
            var trackList = Array<TrackItem>()
            for location in self{
                trackList.append(contentsOf: location.tracks)
            }
            trackList.sortByDate()
            return trackList
        }
    }
    
    var images: Array<ImageItem>{
        get{
            var imageList = Array<ImageItem>()
            for location in self{
                imageList.append(contentsOf: location.images)
            }
            imageList.sort()
            return imageList
        }
    }
    
    var fileItems: FileItemList{
        get{
            var fileList = FileItemList()
            for location in self{
                fileList.append(contentsOf: location.fileItems)
            }
            return fileList
        }
    }
    
    func updateCreationDates(){
        for location in self{
            if !location.items.isEmpty{
                var creationDate = Date.localDate
                for item in location.items{
                    if item.creationDate < creationDate{
                        creationDate = item.creationDate
                    }
                }
                if creationDate < location.creationDate{
                    location.creationDate = creationDate
                }
            }
        }
    }
    
    mutating func removeDuplicates(){
        for location in self{
            let duplicates = getDuplicates(of: location)
            if duplicates.count > 0{
                Log.warn("removing \(count) duplicates of id \(location.id)")
            }
            for duplicate in duplicates{
                self.remove(duplicate)
            }
            location.items.removeDuplicates()
        }
    }
    
    func getDuplicates(of location: Location) -> LocationList{
        var list = LocationList()
        for otherLocation in self{
            if location != otherLocation, location.equals(otherLocation){
                list.append(otherLocation)
            }
        }
        return list
    }
    
}
