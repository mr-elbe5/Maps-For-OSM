/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UniformTypeIdentifiers

extension URL {
    
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    var isAlias: Bool {
        (try? resourceValues(forKeys: [.isAliasFileKey]))?.isAliasFile == true
    }
    
    var utType: UTType?{
        UTType(filenameExtension: self.pathExtension)
    }

}
