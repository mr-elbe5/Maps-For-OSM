/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CoreLocation
import CloudKit
import UIKit
import E5Data
import E5IOSUI
import E5MapData
import E5IOSMapUI
import E5PhotoLib

protocol AppLoaderDelegate{
    func startSpinner() -> UIActivityIndicatorView
    func stopSpinner(_ spinner: UIActivityIndicatorView?)
    func dataChanged()
}

struct AppLoader{
    
    static var delegate: AppLoaderDelegate? = nil
    
    static func initialize(){
        AppURLs.initialize()
        MapTile.tilesDirURL = AppURLs.tilesDirURL
        loadPreferences()
        loadAppState()
        PhotoLibrary.initializeAlbum(albumName: "MapsForOSM")
    }
    
    static func loadPreferences(){
        if let prefs : Preferences = UserDefaults.standard.load(forKey: Preferences.storeKey){
            Preferences.shared = prefs
        }
        else{
            Log.info("no saved data available for preferences")
            Preferences.shared = Preferences()
        }
    }
    
    static func loadAppState(){
        if let state : AppState = UserDefaults.standard.load(forKey: AppState.storeKey){
            AppState.shared = state
        }
        else{
            Log.info("no saved data available for state")
            AppState.shared = AppState()
        }
    }
    
    static func loadData(delegate: AppLoaderDelegate? = nil){
        //Log.debug("loading from user defaults")
        loadFromUserDefaults()
        if Preferences.shared.useICloud{
            CKContainer.default().accountStatus(){ status, error in
                if status == .available{
                    //Log.debug("loading from iCloud")
                    DispatchQueue.main.async{
                        loadDataFromICloud(delegate: delegate)
                    }
                }
                else{
                    Log.warn("iCloud not available")
                }
            }
        }
    }
    
    static func loadDataFromICloud(delegate: AppLoaderDelegate? = nil){
        let synchronizer = CloudSynchronizer()
        let spinner = delegate?.startSpinner()
        Task{
            try await synchronizer.synchronizeFromICloud(deleteLocalData: false)
            DispatchQueue.main.async{
                delegate?.stopSpinner(spinner)
                delegate?.dataChanged()
            }
            AppData.shared.saveLocally()
        }
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
    
    static func saveData(delegate: AppLoaderDelegate? = nil){
        if Preferences.shared.useICloud{
            let spinner = delegate?.startSpinner()
            let synchronizer = CloudSynchronizer()
            Task{
                try await synchronizer.synchronizeToICloud(deleteICloudData: true)
                AppData.shared.saveLocally()
                DispatchQueue.main.async{
                    self.delegate?.stopSpinner(spinner)
                }
            }
        }
        else{
            AppData.shared.saveLocally()
        }
    }
    
}
