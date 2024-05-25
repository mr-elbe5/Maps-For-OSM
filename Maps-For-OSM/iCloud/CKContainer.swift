/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit
import E5Data

extension CKContainer{
    
    static var mapsForOSMContainerName = "iCloud.MapsForOSM"
    
    static var container = CKContainer(identifier: mapsForOSMContainerName)
    static var privateDatabase = container.privateCloudDatabase
    
    static func isConnected() async throws -> Bool{
        let status = try await container.accountStatus()
        Log.info("account status = \(status == .available ? "connected" : "disconnected")")
        return status == .available
    }
    
}
