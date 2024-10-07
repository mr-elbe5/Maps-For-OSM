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
    
    var messages = [String]()
    
    var session: WCSession?

    override init() {
        session = WCSession.default
        super.init()
        session?.delegate = self
        session?.activate()
    }

    func requestInfo() {
        print("requsetInfo")
        let request = ["request": "date"]
        print(session?.activationState ?? .notActivated)
        session?.sendMessage(
            request,
            replyHandler: { response in
                debugPrint("Received response", response)
                DispatchQueue.main.async {
                    self.messages.append("Reply: \(response)")
                }
            },
            errorHandler: { error in
                debugPrint("Error sending message:", error)
            }
        )
    }
}

extension PhoneConnector: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith activationState:\(activationState.rawValue), error: \(String(describing: error))")
    }
}
