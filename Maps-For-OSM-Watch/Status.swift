import Foundation
import SwiftUI
import CoreLocation

@Observable class Status: NSObject{
    
    static var instance = Status()
    
    var zoom : Int = 16
    var viewSize: CGSize = CGSize(width: 158, height: 145)
    
    var viewCenter : CGPoint{
        CGPoint(x: viewSize.width/2, y: viewSize.height/2)
    }
    
    func setViewSize(_ size: CGSize) -> Bool{
        viewSize = size
        print(viewSize)
        return true
    }
    
}
