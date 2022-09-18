/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class UserLocationView : UIView{
    
    static var userLocationColor = UIColor.systemBlue
    static var userDirectionColor = UIColor.red
    
    let locationRadius : CGFloat = 16
    
    var drawCenter : CGPoint? = nil
    var accuracy: CLLocationAccuracy = 100
    var planetPoint : CGPoint = .zero
    var direction : CLLocationDirection = 0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func updateLocationPoint(planetPoint: CGPoint, accuracy: CLLocationAccuracy, offset: CGPoint, scale: CGFloat){
        self.planetPoint = planetPoint
        self.accuracy = accuracy
        updatePosition(offset: offset, scale: scale)
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let normalizedOffset = NormalizedPlanetPoint(pnt: CGPoint(x: offset.x/scale, y: offset.y/scale))
        drawCenter = CGPoint(x: (planetPoint.x - normalizedOffset.point.x)*scale , y: (planetPoint.y - normalizedOffset.point.y)*scale)
        setNeedsDisplay()
    }
    
    func updateDirection(direction: CLLocationDirection){
        self.direction = direction
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let drawCenter = drawCenter{
            let drawRect = CGRect(x: drawCenter.x - locationRadius , y: drawCenter.y - locationRadius, width: 2*locationRadius, height: 2*locationRadius)
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
            ctx.addEllipse(in: drawRect.scaleCenteredBy(0.3))
            ctx.setFillColor(color)
            ctx.drawPath(using: .fill)
            ctx.beginPath()
            ctx.setLineWidth(2.0)
            ctx.addEllipse(in: drawRect.scaleCenteredBy(0.6))
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
    
}
