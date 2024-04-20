/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

struct AuthorizationError: Swift.Error {
    var errorDescription: String? {
        return "authorizationError".localize(table: "Base")
    }
}
