/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

typealias PlaceList = Array<Place>

extension PlaceList{
    
    mutating func remove(_ place: Place){
        removeAll(where: {
           $0 == place
        })
    }
    
    mutating func removePlaces(of list: PlaceList){
        for place in list{
            remove(place)
        }
    }
    
    var allSelected: Bool{
        get{
            !contains(where: {
                !$0.selected
            })
        }
    }
    
    var allUnselected: Bool{
        get{
            !contains(where: {
                $0.selected
            })
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
    mutating func sortAll(){
        self.sort()
        for place in self{
            place.sortItems()
        }
    }
    
    var filteredPlaces : PlaceList{
        switch AppState.shared.placeFilter{
        case .all: return self
        case .media:
            return self.filter({
                $0.hasMedia
            })
        case .track:
            return self.filter({
                $0.hasTrack
            })
        case .note:
            return self.filter({
                $0.hasNote
            })
        }
    }
    
    var trackItems: Array<TrackItem>{
        get{
            var trackList = Array<TrackItem>()
            for place in self{
                trackList.append(contentsOf: place.tracks)
            }
            trackList.sortByDate()
            return trackList
        }
    }
    
    var imageItems: Array<ImageItem>{
        get{
            var imageList = Array<ImageItem>()
            for place in self{
                imageList.append(contentsOf: place.images)
            }
            imageList.sortByDate()
            return imageList
        }
    }
    
    var fileItems: FileItemList{
        get{
            var fileList = FileItemList()
            for place in self{
                fileList.append(contentsOf: place.fileItems)
            }
            return fileList
        }
    }
    
    func updateCreationDates(){
        for place in self{
            if !place.allItems.isEmpty{
                var creationDate = Date()
                for item in place.allItems{
                    if item.creationDate < creationDate{
                        creationDate = item.creationDate
                    }
                }
                if creationDate < place.creationDate{
                    place.creationDate = creationDate
                }
            }
        }
    }
    
}
