/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5Data
import E5MapData
import CoreLocation

protocol EditTrackMapDelegate{
    func trackpointChangedInMap(_ trackpoint: Trackpoint)
}

class EditTrackMapView : NSClipView{
    
    var track: Track
    
    var boundingTrackRect: CGRect = .zero
    var zoom = World.maxZoom
    var downScale: CGFloat{
        World.zoomScale(from: World.maxZoom, to: zoom)
    }
    var scaledWorldViewRect: CGRect = .zero
    var worldViewRect: CGRect = .zero
    
    var drawTrackPoints = Array<DrawTrackpoint>()
    
    var delegate: EditTrackMapDelegate? = nil
    
    init(track: Track){
        self.track = track
        super.init(frame: .zero)
        backgroundColor = .clear
        postsFrameChangedNotifications = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        if !track.trackpoints.isEmpty{
            boundingTrackRect = track.trackpoints.boundingMapRect!
            //Log.info("boundingTrackRect = \(boundingTrackRect)")
            zoom = World.getZoomToFit(worldRect: boundingTrackRect, scaledSize: newSize)
            //Log.info("zoom = \(zoom)")
            //Log.info("downScale = \(downScale)")
            let centerCoordinate = boundingTrackRect.centerCoordinate
            //Log.info("centerCoordinate = \(centerCoordinate)")
            let centerPoint = CGPoint(x: World.scaledX(centerCoordinate.longitude, downScale: downScale), y: World.scaledY(centerCoordinate.latitude, downScale: downScale))
            //Log.info("centerPoint = \(centerPoint)")
            scaledWorldViewRect = CGRect(x: centerPoint.x - newSize.width/2, y: centerPoint.y - newSize.height/2, width: newSize.width, height: newSize.height)
            //Log.info("scaledWorld = \(World.scaledWorld(zoom: zoom))")
            worldViewRect = World.worldRect(scaledRect: scaledWorldViewRect, downScale: downScale)
            //Log.info("worldViewRect = \(worldViewRect)")
            setDrawTrackPoints()
            setMarkers()
        }
        super.setFrameSize(newSize)
    }
    
    func setDrawTrackPoints(){
        drawTrackPoints.removeAll()
        for idx in 0..<track.trackpoints.count{
            let trackpoint = track.trackpoints[idx]
            let mapPoint = CGPoint(trackpoint.coordinate)
            let drawPoint = CGPoint(x: (mapPoint.x - worldViewRect.minX)*downScale, y: (mapPoint.y - worldViewRect.minY)*downScale)
            drawTrackPoints.append(DrawTrackpoint(trackpoint: trackpoint, drawpoint: drawPoint, zoom: zoom))
        }
    }
    
    func setMarkers() {
        removeAllSubviews()
        if !track.trackpoints.isEmpty{
            for idx in 0..<drawTrackPoints.count{
                let btn = TrackpointMarker(point: drawTrackPoints[idx])
                addSubview(btn)
                btn.delegate = self
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        Log.info("start draw")
        if !worldViewRect.isEmpty{
            let ctx = NSGraphicsContext.current!.cgContext
            drawTiles()
            drawTrack(ctx)
        }
        Log.info("start draw markers")
        super.draw(dirtyRect)
        Log.info("end draw markers")
    }
    
    func drawTiles() {
        let drawTileList = DrawTileList.getDrawTiles(size: bounds.size, zoom: zoom, downScale: downScale, scaledWorldViewRect: scaledWorldViewRect)
        if drawTileList.assertDrawTileImages(){
            drawTileList.draw()
        }
    }
    
    func drawTrack(_ ctx: CGContext) {
        if !drawTrackPoints.isEmpty{
            ctx.beginPath()
            ctx.move(to: drawTrackPoints[0].drawpoint)
            for idx in 1..<drawTrackPoints.count{
                ctx.addLine(to: drawTrackPoints[idx].drawpoint)
            }
            ctx.setStrokeColor(NSColor.systemOrange.cgColor)
            ctx.setLineWidth(2.0)
            ctx.drawPath(using: .stroke)
        }
    }
    
    func trackpointChangedInList(_ trackpoint: Trackpoint) {
        for sv in subviews{
            if let marker = sv as? TrackpointMarker, marker.point.trackpoint.id == trackpoint.id{
                marker.needsDisplay = true
            }
        }
    }
    
    func trackpointsChanged(){
        setDrawTrackPoints()
        setMarkers()
        needsDisplay = true
    }
    
}

extension EditTrackMapView: TrackpointMarkerDelegate{
    
    func pointTapped(_ editpoint: DrawTrackpoint) {
        delegate?.trackpointChangedInMap(editpoint.trackpoint)
    }
    
    func markerMoved(){
        needsDisplay = true
    }
    
}
