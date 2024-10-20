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
        let request = ["request": "tileImageData", "zoom": tileData.zoom, "x": tileData.tileX, "y": tileData.tileY] as [String : Any]
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
    
}
