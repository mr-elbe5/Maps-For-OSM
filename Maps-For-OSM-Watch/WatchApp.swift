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
    
    override init(){
        FileManager.initializePrivateDir()
        FileManager.initializeTilesDir()
        //print("tiles dir exists: \(FileManager.default.fileExists(url: FileManager.tilesDirURL))")
        //TileProvider.instance.dumpTiles()
        Log.useCache = false
        Log.logLevel = .info
    }
    
    func applicationDidFinishLaunching() {
        print("app did finish launching")
    }

    func applicationDidBecomeActive(){
        print("app did become active")
    }
    
    func applicationWillResignActive(){
        //LocationManager.instance.stop()
        print("app will resign active")
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
    
    @State var status = AppStatus()
    @State var locationManager = LocationManager()
    
    @State var appStatus = AppStatus()
    @State var mapStatus = MapStatus()
    @State var directionStatus = DirectionStatus()
    @State var trackStatus = TrackStatus()
    @State var healthStatus = HealthStatus()
    
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView(appStatus: $appStatus, mapStatus: $mapStatus, directionStatus: $directionStatus, trackStatus: $trackStatus, healthStatus: $healthStatus)
                .onAppear(){
                    locationManager.start()
                }
        }
        .onChange(of: locationManager.location){
            DispatchQueue.main.async {
                mapStatus.location = locationManager.location
                mapStatus.update()
            }
        }
        .onChange(of: locationManager.direction){
            DispatchQueue.main.async {
                directionStatus.direction = locationManager.direction
            }
        }
    }

}

