import Foundation
import SwiftUI
import CoreLocation

@Observable class AppStatus: NSObject{
    
    static var shared = AppStatus()

    var mainViewFrame = CGRect()
    
}
