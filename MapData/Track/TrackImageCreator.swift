/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import E5Data
import CoreLocation

open class TrackImageCreator{
    
    public var track: Track
    
    public init(track: Track){
        self.track = track
    }
    
#if os(macOS)
    
    public func createImage(size: NSSize) -> NSImage?{
        if track.trackpoints.isEmpty{
            return nil
        }
        let boundingTrackRect = track.trackpoints.boundingMapRect!
        let zoom = World.getZoomToFit(worldRect: boundingTrackRect, scaledSize: size)
        let downScale = World.zoomScale(from: World.maxZoom, to: zoom)
        let centerCoordinate = boundingTrackRect.centerCoordinate
        let centerPoint = CGPoint(x: World.scaledX(centerCoordinate.longitude, downScale: downScale), y: World.scaledY(centerCoordinate.latitude, downScale: downScale))
        let scaledWorldViewRect = CGRect(x: centerPoint.x - size.width/2, y: centerPoint.y - size.height/2, width: size.width, height: size.height)
        let worldViewRect = World.worldRect(scaledRect: scaledWorldViewRect, downScale: downScale)
        if worldViewRect.isEmpty{
            return nil
        }
        let drawTileList = DrawTileList.getDrawTiles(size: size, zoom: zoom, downScale: downScale, scaledWorldViewRect: scaledWorldViewRect)
        if !drawTileList.assertDrawTileImages(){
            return nil
        }
        let img = NSImage(size: size, flipped: true){ rect in
            let ctx = NSGraphicsContext.current!.cgContext
            drawTileList.draw()
            self.drawTrack(ctx: ctx, size: size, zoom: zoom, downScale: downScale, worldViewRect: worldViewRect)
            return true
        }
        return img
    }
    
    public func drawTrack(ctx: CGContext, size: NSSize, zoom: Int, downScale: CGFloat, worldViewRect: CGRect) {
        if !track.trackpoints.isEmpty{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<track.trackpoints.count{
                let trackpoint = track.trackpoints[idx]
                let mapPoint = CGPoint(trackpoint.coordinate)
                let drawPoint = CGPoint(x: (mapPoint.x - worldViewRect.minX)*downScale, y: (mapPoint.y - worldViewRect.minY)*downScale)
                //Log.info("drawPoint = \(drawPoint)")
                drawPoints.append(drawPoint)
            }
            ctx.beginPath()
            ctx.move(to: drawPoints[0])
            for idx in 1..<drawPoints.count{
                ctx.addLine(to: drawPoints[idx])
            }
            ctx.setStrokeColor(NSColor.systemOrange.cgColor)
            ctx.setLineWidth(2.0)
            ctx.drawPath(using: .stroke)
        }
    }
    
#elseif os(iOS)
    
    public func createImage(size: CGSize) -> UIImage?{
        if track.trackpoints.isEmpty{
            return nil
        }
        let boundingTrackRect = track.trackpoints.boundingMapRect!
        let zoom = World.getZoomToFit(worldRect: boundingTrackRect, scaledSize: size)
        let downScale = World.zoomScale(from: World.maxZoom, to: zoom)
        let centerCoordinate = boundingTrackRect.centerCoordinate
        let centerPoint = CGPoint(x: World.scaledX(centerCoordinate.longitude, downScale: downScale), y: World.scaledY(centerCoordinate.latitude, downScale: downScale))
        let scaledWorldViewRect = CGRect(x: centerPoint.x - size.width/2, y: centerPoint.y - size.height/2, width: size.width, height: size.height)
        let worldViewRect = World.worldRect(scaledRect: scaledWorldViewRect, downScale: downScale)
        if worldViewRect.isEmpty{
            return nil
        }
        let drawTileList = DrawTileList.getDrawTiles(size: size, zoom: zoom, downScale: downScale, scaledWorldViewRect: scaledWorldViewRect)
        if !drawTileList.assertDrawTileImages(){
            return nil
        }
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image(){ ctx in
            drawTileList.draw()
            self.drawTrack(ctx: ctx.cgContext, size: size, zoom: zoom, downScale: downScale, worldViewRect: worldViewRect)
        }
        return img
    }
    
    public func drawTrack(ctx: CGContext, size: CGSize, zoom: Int, downScale: CGFloat, worldViewRect: CGRect) {
        if !track.trackpoints.isEmpty{
            var drawPoints = Array<CGPoint>()
            for idx in 0..<track.trackpoints.count{
                let trackpoint = track.trackpoints[idx]
                let mapPoint = CGPoint(trackpoint.coordinate)
                let drawPoint = CGPoint(x: (mapPoint.x - worldViewRect.minX)*downScale, y: (mapPoint.y - worldViewRect.minY)*downScale)
                //Log.info("drawPoint = \(drawPoint)")
                drawPoints.append(drawPoint)
            }
            ctx.beginPath()
            ctx.move(to: drawPoints[0])
            for idx in 1..<drawPoints.count{
                ctx.addLine(to: drawPoints[idx])
            }
            ctx.setStrokeColor(UIColor.systemOrange.cgColor)
            ctx.setLineWidth(2.0)
            ctx.drawPath(using: .stroke)
        }
    }
    
#endif
    
}

