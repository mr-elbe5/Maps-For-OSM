/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }


}

func debug(_ msg: String){
    //print("error: \(msg)")
}

func info(_ msg: String){
    print("info: \(msg)")
}

func warn(_ msg: String){
    print("warn: \(msg)")
}

func error(_ msg: String){
    print("error: \(msg)")
}

func error(_ msg: String, error: Error){
    print("error: \(msg): \(error.localizedDescription)")
}

func error(error: Error){
    print("error: \(error.localizedDescription)")
}

func logError(_ msg: String, error: Error){
    print("error: \(msg): \(error.localizedDescription)")
}


