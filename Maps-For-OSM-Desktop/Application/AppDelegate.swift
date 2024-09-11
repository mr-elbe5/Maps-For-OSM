/*
Maps For OSM
App for display and use of OSM maps without MapKit
Copyright: Michael Rönnau mr@elbe5.de
*/

import AppKit
import E5Data

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        Log.useCache = false
        Log.logLevel = .error
        FileManager.initializePrivateDir()
        FileManager.default.initializeAppDirs()
        //FileManager.default.logFileInfo()
        World.setMaxZoom(20)
        World.scrollWidthFactor = 1
        if let prefs : MacPreferences = UserDefaults.standard.load(forKey: Preferences.storeKey){
            Preferences.shared = prefs
        }
        else{
            Log.info("no saved data available for preferences")
            Preferences.shared = MacPreferences()
        }
        if let state : MacAppState = UserDefaults.standard.load(forKey: AppState.storeKey){
            AppState.shared = state
            Log.info("last location: \(AppState.shared.coordinate)")
            Log.info("last zoom: \(AppState.shared.zoom)")
        }
        else{
            Log.info("no saved data available for state")
            AppState.shared = MacAppState()
        }
        AppData.shared.load()
        createMenu()
        NSApp.appearance = NSAppearance(named: .darkAqua)
        MainWindowController.instance.showWindow(nil)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Preferences.shared.save()
        AppState.shared.save()
        AppData.shared.save()
        let count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.info("\(count) temporary files deleted")
        }
    }
    
    func createMenu(){
        let mainMenu = NSMenu()
        
        let appMenu = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        appMenu.submenu = NSMenu(title: "")
        appMenu.submenu?.addItem(withTitle: "aboutMapsForOSM".localize(), action: #selector(openAbout), keyEquivalent: "n")
        appMenu.submenu?.addItem(NSMenuItem.separator())
        appMenu.submenu?.addItem({ () -> NSMenuItem in
            let m = NSMenuItem(title: "preferences".localize(), action: #selector(openPreferences), keyEquivalent: ",")
            m.keyEquivalentModifierMask = [.command]
            return m
        }())
        appMenu.submenu?.addItem(NSMenuItem.separator())
        appMenu.submenu?.addItem(withTitle: "hideMe".localize(), action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.submenu?.addItem({ () -> NSMenuItem in
            let m = NSMenuItem(title: "hideOthers".localize(), action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
            m.keyEquivalentModifierMask = [.command, .option]
            return m
        }())
        appMenu.submenu?.addItem(withTitle: "showAll".localize(), action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.submenu?.addItem(NSMenuItem.separator())
        let appServicesMenu     = NSMenu()
        NSApp.servicesMenu      = appServicesMenu
        appMenu.submenu?.addItem(withTitle: "services".localize(), action: nil, keyEquivalent: "").submenu = appServicesMenu
        appMenu.submenu?.addItem(NSMenuItem.separator())
        appMenu.submenu?.addItem(withTitle: "quitMapsForOSM".localize(), action: #selector(quitApp), keyEquivalent: "q")
        
        let appWindowMenu     = NSMenu(title: "window".localize())
        NSApp.windowsMenu     = appWindowMenu
        let windowMenu = NSMenuItem(title: "window".localize(), action: nil, keyEquivalent: "")
        windowMenu.submenu = appWindowMenu
        
        let helpMenu = NSMenuItem(title: "help".localize(), action: nil, keyEquivalent: "")
        helpMenu.submenu = NSMenu(title: "help".localize())
        helpMenu.submenu?.addItem(withTitle: "mapsForOSMHelp".localize(), action: #selector(openHelp), keyEquivalent: "o")
        
        
        mainMenu.addItem(appMenu)
        mainMenu.addItem(windowMenu)
        mainMenu.addItem(helpMenu)
        
        NSApp.mainMenu = mainMenu
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openAbout() {
        NSApplication.shared.orderFrontStandardAboutPanel(nil)
    }
    
    @objc func openPreferences() {
        MainViewController.instance.openPreferences()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func openHelp() {
        MainViewController.instance.openHelp()
    }
    
}


