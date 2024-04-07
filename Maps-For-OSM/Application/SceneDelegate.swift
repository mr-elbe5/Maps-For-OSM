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
        AppLoader.initialize()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let mainViewController = MainViewController()
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        LocationService.shared.serviceDelegate = mainViewController
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
        AppLoader.saveInitalizationData()
        AppLoader.saveData()
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
