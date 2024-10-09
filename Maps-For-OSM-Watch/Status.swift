import Foundation
import SwiftUI
import CoreLocation

@Observable class Status: NSObject{
    
    static var instance = Status()
    
    var zoom : Int = 16
    
}
