/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

struct GenericError: Error {
    
    var text: String
    
    init(_ text: String){
        self.text = text
    }
    
    var errorDescription: String? {
        return text.localize()
    }
    
}
