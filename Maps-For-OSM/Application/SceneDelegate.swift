/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Log.info("SceneDelegate will connect")
        AppState.loadInstance()
        FileController.initialize()
        Preferences.loadInstance()
        TrackPool.load()
        LocationPool.load()
        AppState.shared.version = AppState.currentVersion
        AppState.shared.save()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        mainController = MainViewController()
        window?.rootViewController = mainController
        window?.makeKeyAndVisible()
        LocationService.shared.requestWhenInUseAuthorization()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Log.info("SceneDelegate did disconnect")
        LocationService.shared.stop()
        FileController.deleteTemporaryFiles()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Log.info("SceneDelegate becoming active")
        if !LocationService.shared.running{
            LocationService.shared.start()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Log.info("SceneDelegate resigning active")
        AppState.shared.save()
        Preferences.shared.save()
        LocationPool.save()
        TrackPool.save()
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

var mainController : MainViewController!
