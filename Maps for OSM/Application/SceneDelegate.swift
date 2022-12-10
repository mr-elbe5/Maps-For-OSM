/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //TestCenter.testWorld()
        FileController.initialize()
        Preferences.loadInstance()
        AppState.initialize()
        AppState.loadInstance()
        //MapTiles.dumpTiles()
        Locations.load()
        Tracks.load()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        mainController = MainViewController()
        window?.rootViewController = mainController
        window?.makeKeyAndVisible()
        LocationService.instance.requestWhenInUseAuthorization()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        LocationService.instance.stop()
        FileController.deleteTemporaryFiles()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if !LocationService.instance.running{
            LocationService.instance.start()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        AppState.shared.save()
        if TrackRecorder.isRecording{
            if !LocationService.instance.authorizedForTracking{
                LocationService.instance.requestAlwaysAuthorization()
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        LocationService.instance.start()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        AppState.shared.save()
        Locations.save()
        Tracks.save()
        if !TrackRecorder.isRecording{
            LocationService.instance.stop()
        }
        Preferences.shared.save()
        mainController.mapView.savePosition()
    }

}

var mainController : MainViewController!

