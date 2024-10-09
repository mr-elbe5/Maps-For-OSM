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

    func applicationDidBecomeActive(){
        FileManager.initializePrivateDir()
        FileManager.initializeTilesDir()
        //print("tiles dir exists: \(FileManager.default.fileExists(url: FileManager.tilesDirURL))")
        //TileProvider.instance.dumpTiles()
        Log.useCache = false
        Log.logLevel = .info
    }
    
    func applicationWillResignActive(){
    }

}

@main
struct WatchApp: App {
    
    @State var status = Status()
    @State var locationManager = LocationManager()
    
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

