import Foundation
import SwiftUI
import CoreLocation

@Observable class Status: NSObject{
    
    static var instance = Status()
    
    var zoom : Int = 16
    var screenSize: CGSize = CGSize(width: 158, height: 145)
    
    var screenCenter : CGPoint{
        CGPoint(x: screenSize.width/2, y: screenSize.height/2)
    }
    
    func setScreenSize() -> Bool{
        let device = WKInterfaceDevice.current()
        let bounds = device.screenBounds
        screenSize = CGSize(width: bounds.width, height: bounds.height)
        print(screenSize)
        return true
    }
    
}
