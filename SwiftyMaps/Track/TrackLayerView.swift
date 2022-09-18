/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class TrackLayerView: UIView {
    
    var offset = CGPoint()
    var scale : CGFloat = 1.0
    var normalizedOffset = NormalizedPlanetPoint(pnt: CGPoint())
    
    var track : TrackData? = nil
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    func setTrack(track: TrackData? = nil){
        self.track = track
        setNeedsDisplay()
    }
    
    func updateTrack(){
        setNeedsDisplay()
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        self.offset = offset
        self.scale = scale
        normalizedOffset = NormalizedPlanetPoint(pnt: CGPoint(x: offset.x/scale, y: offset.y/scale))
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let track = track{
            if !track.trackpoints.isEmpty{
                let color = UIColor.systemOrange.cgColor
                let ctx = UIGraphicsGetCurrentContext()!
                ctx.beginPath()
                ctx.move(to: getPoint(track.trackpoints[0]))
                for idx in 1..<track.trackpoints.count{
                    ctx.addLine(to: getPoint(track.trackpoints[idx]))
                }
                ctx.setStrokeColor(color)
                ctx.setLineWidth(4.0)
                ctx.drawPath(using: .stroke)
            }
        }
    }
    
    func getPoint(_ trackPoint: TrackPoint) -> CGPoint{
        let locationPoint = World.planetPointFromCoordinate(coordinate: trackPoint.coordinate)
        return CGPoint(x: (locationPoint.x - normalizedOffset.point.x)*scale , y: (locationPoint.y - normalizedOffset.point.y)*scale)
    }
    
}


