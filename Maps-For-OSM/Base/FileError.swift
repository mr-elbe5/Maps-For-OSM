/*
 E5Cam
 Simple Camera
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
        case .read: return "readFileError".localize(table: "Base")
        case .save: return "saveFileError".localize(table: "Base")
        case .unauthorized: return "unauthorizedError".localize(table: "Base")
        case .unexpected: return "unexpectedError".localize(table: "Base")
        }
    }
}

