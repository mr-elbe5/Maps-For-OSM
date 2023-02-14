/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

enum AuthorizationError: Swift.Error {
    case rejected
    case unexpected
}

extension AuthorizationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .rejected: return "rejectedError".localize()
        case .unexpected: return "unexpectedError".localize()
        }
    }
}
