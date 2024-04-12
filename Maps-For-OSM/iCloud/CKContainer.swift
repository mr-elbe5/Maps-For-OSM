/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import CloudKit

extension CKContainer{
    
    static var container = CKContainer(identifier: CloudSynchronizer.mapsForOSMContainerName)
    static var privateDatabase = container.privateCloudDatabase
    
    static func isConnected() async throws -> Bool{
        return try await container.accountStatus() == .available
    }
    
}
