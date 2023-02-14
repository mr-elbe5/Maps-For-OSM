/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class UserLocationView : UIButton{
    
    static var userLocationColor = UIColor.systemBlue
    static var userDirectionColor = UIColor.red
    
    static let frameRect = CGRect(x: 0, y: 0, width: 32, height: 32)
    
    let locationRadius : CGFloat = frameRect.width/2
    
    var scale : CGFloat = 1.0
    var accuracy: CLLocationAccuracy = 100
    var planetPoint : CGPoint = .zero
    var direction : CLLocationDirection = 0
    
    func updateLocationPoint(planetPoint: CGPoint, accuracy: CLLocationAccuracy, offset: CGPoint, scale: CGFloat){
        self.planetPoint = planetPoint
        self.accuracy = accuracy
        updatePosition(offset: offset, scale: scale)
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let mapOffset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
        let drawCenter = CGPoint(x: (planetPoint.x - mapOffset.x)*scale , y: (planetPoint.y - mapOffset.y)*scale)
        self.frame = CGRect(x: drawCenter.x - locationRadius , y: drawCenter.y - locationRadius, width: 2*locationRadius, height: 2*locationRadius)
        self.scale = scale
        setNeedsDisplay()
    }
    
    func updateDirection(direction: CLLocationDirection){
        self.direction = direction
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let drawCenter = CGPoint(x: locationRadius, y: locationRadius)
        let ctx = UIGraphicsGetCurrentContext()!
        var color : CGColor!
        if accuracy <= 10{
            color = UserLocationView.userLocationColor.cgColor
        }
        else{
            let redFactor = max(1.0, accuracy/100.0)
            color = UIColor(red: redFactor, green: 0, blue: 1.0, alpha: 1.0).cgColor
        }
        ctx.beginPath()
        ctx.addEllipse(in: UserLocationView.frameRect.scaleCenteredBy(0.3))
        ctx.setFillColor(color)
        ctx.drawPath(using: .fill)
        
        ctx.beginPath()
        ctx.setLineWidth(2.0)
        ctx.addEllipse(in: UserLocationView.frameRect.scaleCenteredBy(0.6))
        ctx.setStrokeColor(color)
        ctx.drawPath(using: .stroke)
        
        let angle1 = (direction - 15)*CGFloat.pi/180
        let angle2 = (direction + 15)*CGFloat.pi/180
        ctx.beginPath()
        ctx.setFillColor(UserLocationView.userDirectionColor.cgColor)
        ctx.move(to: drawCenter)
        ctx.addLine(to: CGPoint(x: drawCenter.x + locationRadius * sin(angle1), y: drawCenter.y - locationRadius * cos(angle1)))
        ctx.addLine(to: CGPoint(x: drawCenter.x + locationRadius * sin(angle2), y: drawCenter.y - locationRadius * cos(angle2)))
        ctx.closePath()
        ctx.drawPath(using: .fill)
    }
    
}
