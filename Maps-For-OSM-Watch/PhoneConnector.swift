//
//  PhoneMessaging.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import Foundation
import SwiftUI
import WatchConnectivity

@Observable class PhoneConnector: NSObject {
    
    static var instance = PhoneConnector()
    
    var session: WCSession?

    override init() {
        session = WCSession.default
        super.init()
        session?.delegate = self
        session?.activate()
    }

    func requestTile(_ tileData: TileData, completion: @escaping (Bool) -> Void) {
        print("watch requesting tile image data from phone")
        let request = [
            "request": "tileImageData",
            "zoom": tileData.zoom,
            "x": tileData.tileX,
            "y": tileData.tileY
        ] as [String : Any]
        session?.sendMessage(
            request,
            replyHandler: { response in
                DispatchQueue.main.async {
                    if let data = response["imageData"] as? Data {
                        print("watch got tile image data from phone")
                        tileData.imageData = data
                        completion(true)
                    }
                    else{
                        completion(false)
                    }
                }
            },
            errorHandler: { error in
                print("error requesting tile:", error)
                completion(false)
            }
        )
    }
    
    func saveTrack(json: String, completion: @escaping (Bool) -> Void) {
        print("watch saving track")
        let request = ["request": "saveTrack", "json": json] as [String : Any]
        session?.sendMessage(
            request,
            replyHandler: { response in
                DispatchQueue.main.async {
                    if let success = response["success"] as? Bool {
                        if success {
                            print("track saved on phone")
                            completion(true)
                        }
                        else{
                            print("track not saved on phone")
                            completion(false)
                        }
                    }
                    else{
                        completion(false)
                    }
                }
            },
            errorHandler: { error in
                print("Error sending message:", error)
                completion(false)
            }
        )
    }
        
}

extension PhoneConnector: WCSessionDelegate {
    
    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState.rawValue), error: \(String(describing: error))")
    }
    
    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("didReceiveMessage: \(message["request"] as? String ?? "")")
        if let request = message["request"] as? String {
            switch request {
            case "tileUpload":
                let zoom = message["zoom"] as? Int ?? 0
                let x = message["x"] as? Int ?? 0
                let y = message["y"] as? Int ?? 0
                if let data = message["data"] as? Data{
                    let tile = TileData(zoom: zoom, tileX: x, tileY: y)
                    tile.imageData = data
                    if FileManager.default.fileExists(atPath: tile.fileUrl.path()){
                        FileManager.default.deleteFile(url: tile.fileUrl)
                    }
                    if FileManager.default.saveFile(data: data, url: tile.fileUrl){
                        print("file \(tile.fileUrl.lastPathComponent) received from phone")
                        replyHandler(["success": true])
                    }
                    else{
                        print("could not save file \(tile.fileUrl.lastPathComponent)")
                        replyHandler(["success": false])
                    }
                }
                else{
                    replyHandler(["success": false])
                }
            default:
                break
            }
        }
    }
    
}
