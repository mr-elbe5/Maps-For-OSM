/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

enum FileError: Swift.Error {
    case read
    case save
    case unauthorized
    case unexpected
}

extension FileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .read: return "readError".localize()
        case .save: return "saveError".localize()
        case .unauthorized: return "unauthorizedError".localize()
        case .unexpected: return "unexpectedError".localize()
        }
    }
}

