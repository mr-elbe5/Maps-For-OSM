/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import AVKit
import CoreLocation

struct AppLoader{
    
    static func initialize(){
        FileController.initialize()
        loadPreferences()
        loadAppState()
        PhotoLibrary.initializeAlbum(albumName: "MapsForOSM")
    }
    
    static func loadPreferences(){
        Preferences.loadInstance()
    }
    
    static func loadAppState(){
        AppState.loadInstance()
    }
    
    static func loadData(){
        
    }
    
    static func loadFromUserDefaults(){
        PlacePool.load()
        // for previous versions
        TrackPool.load()
        TrackPool.addTracksToPlaces()
        PlacePool.addNotesToPlaces()
    }
    
    static func loadFromICloud(){
        PlacePool.loadFromICloud()
    }
    
    static func saveInitalizationData(){
        AppState.shared.save()
        Preferences.shared.save()
    }
    
    static func saveData(){
        if Preferences.shared.loadFromICloud{
            loadFromICloud()
        }
        else{
            loadFromUserDefaults()
        }
    }
    
    static func saveToUserDefaults(){
        PlacePool.save()
    }
    
    static func saveToICloud(){
        PlacePool.saveToICloud()
    }
    
}
