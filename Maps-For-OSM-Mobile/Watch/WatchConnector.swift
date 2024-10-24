import WatchConnectivity
import E5Data
import UIKit

class WatchConnector: NSObject, ObservableObject {
    
    static let shared = WatchConnector()
    
    var session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
    }
    
    var isActivated: Bool {
        session.activationState == .activated
    }
    
    var isReachable: Bool {
        session.isReachable
    }
    
    func start(){
        session.activate()
        Log.info("watch session is reachable: \(session.isReachable)")
        Log.info("watch session is paired: \(session.isPaired)")
    }
    
    var isWatchConnected: Bool {
        session.activationState == .activated && session.isPaired && session.isReachable
    }
    
    func sendTile(_ tile: MapTile, data: Data, completion: @escaping (Bool) -> Void) {
        Log.debug("sending tile")
        if !isWatchConnected {
            Log.debug("not connected to phone")
            completion(false)
            return
        }
        session.sendMessage([
            "request": "tileUpload",
            "zoom": tile.zoom,
            "x": tile.x,
            "y": tile.y,
            "data": data as Any
        ], replyHandler: {response in
            DispatchQueue.main.async {
                if let success = response["success"] as? Bool {
                    completion(success)
                }
                else{
                    completion(false)
                }
            }
        }) { error in
            Log.error("error sending tile: \(error)")
        }
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
        if let request = message["request"] as? String {
            Log.debug("didReceiveRequest: \(request)")
            switch request {
            case "location":
                if let location = LocationService.shared.location {
                    replyHandler(["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude, "altitude": location.altitude])
                }
                else{
                    replyHandler([:])
                }
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
                        else{
                            replyHandler([:])
                        }
                    }
                }
            case "saveTrack":
                if let json = message["json"] as? String, let track = createTrack(json: json), let coordinate = track.startCoordinate{
                    var location = AppData.shared.getLocation(coordinate: coordinate)
                    if location == nil{
                        location = AppData.shared.createLocation(coordinate: coordinate)
                    }
                    location!.addItem(item: track)
                    AppData.shared.save()
                    Log.info("saved track on phone")
                    replyHandler(["success": true as Any])
                }
                else{
                    replyHandler(["success": false as Any])
                }
            default:
                break;
            }
        }
    }
    
    func createTrack(json: String) -> TrackItem?{
        if let data =  json.data(using: .utf8){
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do{
                let trackpoints: TrackpointList = try decoder.decode(TrackpointList.self, from : data)
                if trackpoints.isEmpty{
                    return nil
                }
                let track = TrackItem()
                track.trackpoints = trackpoints
                track .simplifyTrack()
                track.updateFromTrackpoints()
                track.setNameByDate()
                return track
            }
            catch (let err){
                Log.error(error: err)
            }
        }
        return nil
    }

}
