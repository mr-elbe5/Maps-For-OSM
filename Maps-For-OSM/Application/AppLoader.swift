/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit

protocol AppLoaderDelegate{
    func startLoading()
    func appLoaded()
    func startSaving()
    func appSaved()
    func startSynchronization()
    func appSynchronized()
}

struct AppLoader{
    
    static var delegate: AppLoaderDelegate? = nil
    
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
    
    static func loadData(delegate: AppLoaderDelegate? = nil){
        if Preferences.shared.useICloud{
            CKContainer.default().accountStatus(){ status, error in
                if status == .available{
                    Log.debug("loading from iCloud")
                    loadDataFromICloud(delegate: delegate)
                }
                else{
                    Log.debug("iCloud not available, loading from user defaults")
                    loadFromUserDefaults(delegate: delegate)
                }
            }
        }
        else{
            Log.debug("loading from user defaults")
            loadFromUserDefaults(delegate: delegate)
        }
    }
    
    static func loadDataFromICloud(delegate: AppLoaderDelegate? = nil){
        let synchronizer = CloudSynchronizer()
        delegate?.startLoading()
        Task{
            try await synchronizer.synchronizeFromICloud(replaceLocalData: Preferences.shared.replaceLocalDataOnDownload)
            DispatchQueue.main.async{
                delegate?.appLoaded()
            }
            AppData.shared.saveLocally()
        }
    }
    
    static func loadFromUserDefaults(delegate: AppLoaderDelegate? = nil){
        AppData.shared.loadLocally()
        DispatchQueue.main.async{
            delegate?.appLoaded()
        }
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
    
    static func saveData(delegate: AppLoaderDelegate? = nil){
        if Preferences.shared.useICloud{
            let synchronizer = CloudSynchronizer()
            delegate?.startSaving()
            Task{
                try await synchronizer.synchronizeToICloud(replaceICloudData: Preferences.shared.replaceICloudDataOnUpload)
                DispatchQueue.main.async{
                    delegate?.appSaved()
                }
                AppData.shared.saveLocally()
            }
        }
        else{
            AppData.shared.saveLocally()
        }
    }
    
}
