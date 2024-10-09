import Foundation
import SwiftUI

class AppStatics{
    
    static var screenSize: CGSize = .zero
    static var safeSize: CGSize = .zero
    static var viewSize: CGSize = .zero
    
    static var viewCenter : CGPoint{
        CGPoint(x: viewSize.width/2, y: viewSize.height/2)
    }
    
    static func setSizes(_ geometry: GeometryProxy) -> Bool{
        let device = WKInterfaceDevice.current()
        let bounds = device.screenBounds
        screenSize = CGSize(width: bounds.width, height: bounds.height)
        print("screenSize: \(screenSize)")
        print(geometry.safeAreaInsets)
        safeSize = CGSize(width: screenSize.width - geometry.safeAreaInsets.leading - geometry.safeAreaInsets.trailing, height: screenSize.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom)
        print("safeSize: \(safeSize)")
        viewSize = geometry.size
        print("viewSize: \(viewSize)")
        return true
    }
    
}
