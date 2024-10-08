import Foundation
import SwiftUI
import CoreLocation

@Observable class Status: NSObject{
    
    static var instance = Status()
    
    var zoom : Int = 16
    var screenSize: CGSize = .zero
    var viewSize: CGSize = CGSize(width: 158, height: 145)
    
    var viewCenter : CGPoint{
        CGPoint(x: viewSize.width/2, y: viewSize.height/2)
    }
    
    func setSizes(_ insets: EdgeInsets) -> Bool{
        let device = WKInterfaceDevice.current()
        let bounds = device.screenBounds
        screenSize = CGSize(width: bounds.width, height: bounds.height)
        print(screenSize)
        print(insets)
        viewSize = CGSize(width: screenSize.width - insets.leading - insets.trailing, height: screenSize.height - insets.top - insets.bottom)
        print(viewSize)
        return true
    }
    
}
