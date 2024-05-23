/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import CommonBasics
import IOSBasics

class CurrentLocationView : UIView{
    
    static var currentLocationColor = UIColor.systemBlue
    static var currentDirectionColor = UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 0.8)

    static let frameRect = CGRect(x: 0, y: 0, width: 40, height: 40)
    
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
        let mapOffset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
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
        let angle1 = (direction - 15)*CGFloat.pi/180
        let angle2 = (direction + 15)*CGFloat.pi/180
        
        ctx.beginPath()
        ctx.setFillColor(CurrentLocationView.currentDirectionColor.cgColor)
        ctx.move(to: drawCenter)
        ctx.addLine(to: CGPoint(x: drawCenter.x + locationRadius * sin(angle1), y: drawCenter.y - locationRadius * cos(angle1)))
        ctx.addLine(to: CGPoint(x: drawCenter.x + locationRadius * sin(angle2), y: drawCenter.y - locationRadius * cos(angle2)))
        ctx.closePath()
        ctx.drawPath(using: .fill)
        
        var color : CGColor!
        if accuracy <= 10{
            color = CurrentLocationView.currentLocationColor.cgColor
        }
        else{
            let redFactor = max(1.0, accuracy/100.0)
            color = UIColor(red: redFactor, green: 0, blue: 1.0, alpha: 1.0).cgColor
        }
        
        ctx.beginPath()
        ctx.setLineWidth(2.0)
        ctx.addEllipse(in: CurrentLocationView.frameRect.scaleCenteredBy(0.4))
        ctx.setStrokeColor(color)
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.drawPath(using: .fillStroke)
        
        ctx.beginPath()
        ctx.addEllipse(in: CurrentLocationView.frameRect.scaleCenteredBy(0.2))
        ctx.setFillColor(color)
        ctx.drawPath(using: .fill)
        
    }
    
}
