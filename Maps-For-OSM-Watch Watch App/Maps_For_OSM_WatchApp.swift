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
        Log.useCache = false
        Log.logLevel = .info
        //LocationManager.shared.start()
    }
    
    func applicationWillResignActive(){
        
        FileManager.initializePrivateDir()
        Log.useCache = false
        Log.logLevel = .info
        LocationManager.shared.stop()
    }

}

@main
struct Maps_For_OSM_Watch_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}

