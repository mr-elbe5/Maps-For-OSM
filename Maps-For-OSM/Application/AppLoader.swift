/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit

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
        CKContainer.default().accountStatus(){ status, error in
            if status == .available{
                Log.debug("loading from iCloud")
                loadDataFromICloud()
                return
            }
            else{
                Log.debug("loading from user defaults")
                loadFromUserDefaults()
            }
        }
    }
    
    static func loadDataFromICloud(){
        AppData.shared.loadFromICloud()
    }
    
    static func loadFromUserDefaults(){
        AppData.shared.loadLocally()
        //deprecated
        loadFromPreviousVersions()
    }
    
    static private func loadFromPreviousVersions(){
        TrackPool.load()
        TrackPool.addTracksToPlaces()
        AppData.shared.convertNotes()
    }
    
    static func saveInitalizationData(){
        AppState.shared.save()
        Preferences.shared.save()
    }
    
    static func saveData(){
        CKContainer.default().accountStatus(){ status, error in
            if status == .available{
                Log.debug("saving to iCloud")
                AppData.shared.saveToICloud()
            }
        }
        Log.debug("saving to user defaults")
        AppData.shared.saveLocally()
    }
    
}
