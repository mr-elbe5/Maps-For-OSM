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
        if let prefs : Preferences = DataController.shared.load(forKey: Preferences.storeKey){
            Preferences.shared = prefs
        }
        else{
            Preferences.shared = Preferences()
        }
    }
    
    static func loadAppState(){
        if let state : AppState = DataController.shared.load(forKey: AppState.storeKey){
            AppState.shared = state
        }
        else{
            AppState.shared = AppState()
        }
    }
    
    static func loadData(){
        if Preferences.shared.loadFromICloud{
            loadFromICloud()
        }
        else{
            loadFromUserDefaults()
        }
    }
    
    static func loadFromUserDefaults(){
        AppData.shared.load()
        //deprecated
        loadFromPreviousVersions()
    }
    
    static private func loadFromPreviousVersions(){
        TrackPool.load()
        TrackPool.addTracksToPlaces()
        AppData.shared.convertNotes()
    }
    
    static func loadFromICloud(){
        AppData.shared.loadFromICloud()
    }
    
    static func saveInitalizationData(){
        AppState.shared.save()
        Preferences.shared.save()
    }
    
    static func saveData(){
        if Preferences.shared.loadFromICloud{
            saveToICloud()
        }
        else{
            saveToUserDefaults()
        }
    }
    
    static func saveToUserDefaults(){
        AppData.shared.save()
    }
    
    static func saveToICloud(){
        AppData.shared.saveToICloud()
    }
    
}
