/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data

import E5PhotoLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Log.info("SceneDelegate will connect")
        
        FileManager.initializePrivateDir()
        FileManager.default.initializeAppDirs()
        Log.useCache = true
        Log.logLevel = .info
        PhotoLibrary.initializeAlbum(albumName: "MapsForOSM")
        if let prefs : Preferences = UserDefaults.standard.load(forKey: Preferences.storeKey){
            Preferences.shared = prefs
        }
        else{
            Log.info("no saved data available for preferences")
            Preferences.shared = Preferences()
        }
        if let state : AppState = UserDefaults.standard.load(forKey: AppState.storeKey){
            AppState.shared = state
            Log.info("last location: \(AppState.shared.coordinate)")
            Log.info("last zoom: \(AppState.shared.zoom)")
        }
        else{
            Log.info("no saved data available for state")
            AppState.shared = AppState()
        }
        TrackRecorder.load()
        AppData.shared.load()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let mainViewController = MainViewController()
        let navViewController = UINavigationController(rootViewController: mainViewController)
        navViewController.navigationBar.tintColor = .label
        window?.rootViewController = navViewController
        window?.makeKeyAndVisible()
        LocationService.shared.serviceDelegate = mainViewController
        LocationService.shared.requestWhenInUseAuthorization()
        WatchConnector.instance.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Log.info("SceneDelegate did disconnect")
        TrackRecorder.instance?.save()
        LocationService.shared.stop()
        let count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.info("\(count) temporary files deleted")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Log.info("SceneDelegate becoming active")
        if !LocationService.shared.running{
            LocationService.shared.start()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Log.info("SceneDelegate resigning active, saving state, prferences and data")
        AppState.shared.save()
        Preferences.shared.save()
        AppData.shared.save()
        if TrackRecorder.isRecording{
            if !LocationService.shared.authorizedForTracking{
                LocationService.shared.requestAlwaysAuthorization()
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Log.info("SceneDelegate entering foreground")
        if !LocationService.shared.running{
            LocationService.shared.start()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        Log.info("SceneDelegate entering background")
        if !TrackRecorder.isRecording{
            LocationService.shared.stop()
        }
    }

}
