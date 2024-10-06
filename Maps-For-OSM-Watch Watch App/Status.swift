import Foundation
import SwiftUI
import CoreLocation

@Observable class Status: NSObject{
    
    static var instance = Status()
    
    var zoom : Int = 16
    var screenSize: CGSize = .zero
    
    var screenCenter : CGPoint{
        CGPoint(x: screenSize.width/2, y: screenSize.height/2)
    }
    
}
