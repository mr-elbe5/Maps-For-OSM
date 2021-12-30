/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        FileController.initialize()
        Preferences.loadInstance()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        mainController = MainViewController()
        window?.rootViewController = mainController
        window?.makeKeyAndVisible()
        LocationService.shared.requestWhenInUseAuthorization()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        LocationService.shared.stop()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        LocationService.shared.start()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if ActiveTrack.isTracking && !LocationService.shared.authorizedForTracking{
            LocationService.shared.requestAlwaysAuthorization()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        LocationService.shared.start()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        Locations.save()
        if !ActiveTrack.isTracking{
            LocationService.shared.stop()
        }
        Preferences.instance.save(zoom: mainController.mapView.zoom, currentCenterCoordinate: mainController.mapView.getVisibleCenterCoordinate())
        FileController.deleteTemporaryFiles()
    }


}

var mainController : MainViewController!

