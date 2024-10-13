import Foundation
import SwiftUI

class AppStatics{
    
    static var screenSize: CGSize = .zero
    static var screenCenter : CGPoint{
        CGPoint(x: screenSize.width/2, y: screenSize.height/2)
    }
    
    static func setSizes() -> Bool{
        let device = WKInterfaceDevice.current()
        let bounds = device.screenBounds
        screenSize = CGSize(width: bounds.width, height: bounds.height)
        print("screenSize: \(screenSize)")
        return true
    }
    
    /*static func setGeometrySizes(_ geometry: GeometryProxy) -> Bool{
        print("viewSize: \(geometry.size)")
        safeRect = CGRect(x: geometry.safeAreaInsets.leading, y: geometry.safeAreaInsets.top, width: screenSize.width - geometry.safeAreaInsets.leading - geometry.safeAreaInsets.trailing, height: screenSize.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom)
        print("safeRect: \(safeRect)")
        return true
    }
    */
}
