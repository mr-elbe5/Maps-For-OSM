import WatchConnectivity
import E5Data
import UIKit

class WatchConnector: NSObject, ObservableObject {
    
    static let instance = WatchConnector()
    
    var session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
    }
    
    func start(){
        session.activate()
        Log.info("watch session is reachable: \(session.isReachable)")
        Log.info("watch session is paired: \(session.isPaired)")
    }
    
}

extension WatchConnector: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Log.debug("WCSession activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
        Log.debug("WCSession.isPaired: \(session.isPaired), WCSession.isWatchAppInstalled: \(session.isWatchAppInstalled)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Log.debug("sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Log.debug("sessionDidDeactivate: \(session)")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        Log.debug("sessionWatchStateDidChange: \(session)")
    }
    
    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Log.debug("didReceiveMessage: \(message)")
        if let request = message["request"] as? String {
            switch request {
            case "tileImageData":
                let zoom = message["zoom"] as? Int ?? 0
                let x = message["x"] as? Int ?? 0
                let y = message["y"] as? Int ?? 0
                let mapTile = MapTile(zoom: zoom, x: x, y: y)
                if mapTile.exists, let fileData = FileManager.default.contents(atPath: mapTile.fileUrl.path){
                    replyHandler(["imageData": fileData as Any])
                }
                else{
                    TileProvider.shared.loadTileImage(tile: mapTile, template: Preferences.shared.urlTemplate) { success in
                        if let data = mapTile.imageData {
                            replyHandler(["imageData": data as Any])
                        }
                    }
                }
            case "saveTrack":
                let json = message["json"] as? String ?? ""
                print("saving track on phone")
                replyHandler(["success": true as Any])
            default:
                break;
            }
        }
    }

}
