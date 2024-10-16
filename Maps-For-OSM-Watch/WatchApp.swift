//
//  Maps_For_OSM_WatchApp.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 28.09.24.
//

import SwiftUI

import WatchKit
import E5Data

class WatchAppDelegate: NSObject, WKApplicationDelegate {
    
    var app: WatchApp? = nil
    
    override init(){
        FileManager.initializePrivateDir()
        FileManager.initializeTilesDir()
        //print("tiles dir exists: \(FileManager.default.fileExists(url: FileManager.tilesDirURL))")
        //TileProvider.instance.dumpTiles()
        Log.useCache = false
        Log.logLevel = .info
        if let prefs : WatchPreferences = UserDefaults.standard.load(forKey: WatchPreferences.storeKey){
            WatchPreferences.shared = prefs
        }
        else{
            Log.info("no saved data available for watch preferences")
            WatchPreferences.shared = WatchPreferences()
        }
        LocationStatus.shared.update()
    }
    
    func applicationDidFinishLaunching() {
        print("app did finish launching")
        LocationService.shared.start()
        HealthStatus.shared.startMonitoring()
    }

    func applicationDidBecomeActive(){
        print("app did become active")
        LocationManager.shared.start()
    }
    
    func applicationWillResignActive(){
        //LocationManager.instance.stop()
        print("app will resign active")
        if !TrackStatus.shared.isRecording {
            LocationManager.shared.stop()
        }
    }
    
    func applicationDidEnterBackground() {
        print("app did enter background")
    }
    
    func applicationWillEnterForeground() {
        print("app will enter foreground")
    }

}

@main
struct WatchApp: App {
    
    @State var locationManager = LocationManager.shared
    
    @State var locationStatus = LocationStatus()
    @State var directionStatus = DirectionStatus()
    @State var trackStatus = TrackStatus()
    @State var healthStatus = HealthStatus()
    @State var preferences = WatchPreferences.shared
    
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(locationStatus: $locationStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus, preferences: $preferences)
                .onAppear(){
                    locationStatus.location = locationManager.location
                    locationStatus.update()
                }
        }
        .onChange(of: locationManager.location){
            if preferences.autoUpdateLocation {
                DispatchQueue.main.async {
                    locationStatus.location = locationManager.location
                    locationStatus.update()
                }
            }
        }
        .onChange(of: locationManager.direction){
            if preferences.showDirection {
                DispatchQueue.main.async {
                    directionStatus.direction = locationManager.direction
                }
            }
        }
        .onChange(of: preferences.showDirection){
            LocationManager.shared.updateFollowDirection()
        }
    }

}

