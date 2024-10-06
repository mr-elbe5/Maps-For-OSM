import WatchConnectivity

class WatchConnectionHandler: NSObject, ObservableObject {
    
    static let instance = WatchConnectionHandler()
    
    var session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
}

extension WatchConnectionHandler: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("WCSession activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
        debugPrint("WCSession.isPaired: \(session.isPaired), WCSession.isWatchAppInstalled: \(session.isWatchAppInstalled)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("sessionDidDeactivate: \(session)")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        debugPrint("sessionWatchStateDidChange: \(session)")
    }
    
    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        debugPrint("didReceiveMessage: \(message)")
        if message["request"] as? String == "date" {
            replyHandler(["date": Date()])
        }
    }

}
