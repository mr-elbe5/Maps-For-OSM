/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5Data
import E5MapData


protocol PlainMapScrollViewDelegate{
    func didScroll()
    func didZoom()
}

class PlainMapScrollView : NSScrollView{
    
    var zoom: Int = World.maxZoom
    
    var zoomScale : Double{
        get{
            1.0/World.zoomScaleToWorld(from: AppState.shared.zoom)
        }
    }
    
    var mapWorldView = FlippedView()
    var tileLayerView = TileLayerView()
    
    var mapDelegate: MapScrollViewDelegate? = nil
    
    override func setupView(){
        hasVerticalScroller = true
        hasHorizontalScroller = true
        addFlippedClipView()
        clipView.drawsBackground = false
        mapWorldView.frame = World.scaledWorld(zoom: zoom)
        self.documentView = mapWorldView
        mapWorldView.addSubviewFilling(tileLayerView)
        addScrollNotifications()
    }
    
    func contentPoint(screenPoint: CGPoint) -> CGPoint{
        CGPoint(x: screenPoint.x + contentOffset.x, y: screenPoint.y + contentOffset.y)
    }
    
    func worldPoint(screenPoint: CGPoint) -> CGPoint{
        return CGPoint(x: (screenPoint.x + contentOffset.x)/zoomScale, y: (screenPoint.y + contentOffset.y)/zoomScale)
    }
    
    var screenCenterCoordinate: CLLocationCoordinate2D{
        let point = worldPoint(screenPoint: screenCenter)
        return World.coordinate(worldX: point.x, worldY: point.y)
    }
    
    func screenPoint(point: CGPoint) -> CGPoint{
        return CGPoint(x: (point.x - contentOffset.x)*zoomScale, y: (point.y - contentOffset.y)*zoomScale)
    }
    
    func scrollToScreenPoint(coordinate: CLLocationCoordinate2D, screenPoint: CGPoint){
        let contentPoint = CGPoint(x: World.scaledX(coordinate.longitude, downScale: zoomScale), y: World.scaledY(coordinate.latitude, downScale: zoomScale))
        let scrollPoint = getSafeScrollPoint(contentPoint: contentPoint)
        scrollTo(scrollPoint)
        mapDelegate?.didScroll()
    }
    
    func scrollToScreenCenter(coordinate: CLLocationCoordinate2D){
        scrollToScreenPoint(coordinate: coordinate, screenPoint: screenCenter)
    }
    
    func zoomIn(){
        zoomTo(zoom: zoom + 1)
    }
    
    func zoomOut(){
        zoomTo(zoom: zoom - 1)
    }
    
    func zoomTo(zoom: Int){
        if zoom >= World.minZoom && zoom <= World.maxZoom{
            let oldOffset = contentOffset
            let screencenter = screenCenter
            let zoomScale = pow(2.0,Double(zoom - self.zoom))
            self.zoom = zoom
            mapWorldView.setFrameSize(World.scaledWorld(zoom: zoom).size)
            tileLayerView.refresh()
            scrollTo(NSPoint(x: (oldOffset.x + screencenter.x)*zoomScale - screencenter.x , y: (oldOffset.y + screencenter.y)*zoomScale - screencenter.y))
            reflectScrolledClipView(clipView)
            mapDelegate?.didZoom()
            mapDelegate?.didScroll()
        }
    }
    
    func zoomTo(zoom: Int, at coordinate: CLLocationCoordinate2D){
        if zoom >= World.minZoom && zoom <= World.maxZoom{
            self.zoom = zoom
            mapWorldView.setFrameSize(World.scaledWorld(zoom: zoom).size)
            tileLayerView.refresh()
            scrollToScreenCenter(coordinate: coordinate)
            reflectScrolledClipView(clipView)
            mapDelegate?.didZoom()
            mapDelegate?.didScroll()
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        if !event.modifierFlags.contains(.option){
            super.scrollWheel(with: event)
            return
        }
        let dy = event.deltaY
        if dy > 0.0 {
            zoomIn()
        }
        else if dy < 0.0{
            zoomOut()
        }
    }
    
    @objc override open func scrollViewDidScroll(){
        mapDelegate?.didScroll()
    }
    
}



