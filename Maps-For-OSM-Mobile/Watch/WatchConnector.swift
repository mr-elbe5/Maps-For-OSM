import WatchConnectivity
import E5Data

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
        if message["request"] as? String == "date" {
            replyHandler(["date": Date()])
        }
    }

}
