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
        try! FileManager.default.createDirectory(at: FileManager.tilesDirURL, withIntermediateDirectories: true, attributes: nil)
        FileManager.initialize()
        Log.useCache = false
        Log.logLevel = .info
    }
    
    func applicationWillResignActive(){
        
        FileManager.initializePrivateDir()
        Log.useCache = false
        Log.logLevel = .info
    }

}

@main
struct WatchApp: App {
    
    @State var status = Status()
    @State var locationManager = LocationManager()
    
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}

