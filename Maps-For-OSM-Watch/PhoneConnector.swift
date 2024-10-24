//
//  PhoneMessaging.swift
//  Maps-For-OSM-Watch Watch App
//
//  Created by Michael Rönnau on 06.10.24.
//

import Foundation
import SwiftUI
import CoreLocation
import WatchConnectivity

@Observable class PhoneConnector: NSObject {
    
    static var instance = PhoneConnector()
    
    var session: WCSession = WCSession.default

    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
    
    var isWatchConnected: Bool {
        session.activationState == .activated && session.isReachable
    }
    
    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        print("watch requesting tile image data from phone")
        if !isWatchConnected {
            print("not connected to phone")
            completion(nil)
            return
        }
        let request = [
            "request": "location",
        ] as [String : Any]
        session.sendMessage(
            request,
            replyHandler: { response in
                DispatchQueue.main.async {
                    if let latitude = response["latitude"] as? Double, let longitude = response["longitude"] as? Double, let altitude = response["altitude"] as? Double {
                        print("watch got location from phone")
                        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
                        completion(location)
                    }
                    else{
                        completion(nil)
                    }
                }
            },
            errorHandler: { error in
                print("error requesting location:", error)
                completion(nil)
            }
        )
    }

    func requestTile(_ tileData: TileData, completion: @escaping (Bool) -> Void) {
        print("watch requesting tile image data from phone")
        if !isWatchConnected {
            print("not connected to phone")
            completion(false)
            return
        }
        let request = [
            "request": "tileImageData",
            "zoom": tileData.zoom,
            "x": tileData.tileX,
            "y": tileData.tileY
        ] as [String : Any]
        session.sendMessage(
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
        if !isWatchConnected {
            print("not connected to phone")
            completion(false)
            return
        }
        let request = ["request": "saveTrack", "json": json] as [String : Any]
        session.sendMessage(
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
