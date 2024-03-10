/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

struct AuthorizationError: Swift.Error {
    var errorDescription: String? {
        return "authorizationError".localize(table: "Base")
    }
}
