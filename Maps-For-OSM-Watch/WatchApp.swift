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
        WatchPreferences.loadShared()
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
    
    @State var locationStatus = LocationStatus.shared
    @State var directionStatus = DirectionStatus.shared
    @State var trackStatus = TrackStatus.shared
    @State var heatlthStatus = HealthStatus.shared
    @State var preferences = WatchPreferences.shared
    
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
                    if trackStatus.isRecording {
                        trackStatus.addTrackpoint(from: locationManager.location)
                    }
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
    }

}

