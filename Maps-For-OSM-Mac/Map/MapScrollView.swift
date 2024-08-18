/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5Data
import E5MapData


protocol MapScrollViewDelegate: PlainMapScrollViewDelegate{
    func showLocationDetails(_ location: Location)
    func showLocationGroupDetails(_ locationGroup: LocationGroup)
}

class MapScrollView : PlainMapScrollView{
    
    override var zoom: Int{
        get{
            AppState.shared.zoom
        }
        set{
            AppState.shared.zoom = newValue
        }
    }
    
    override var zoomScale : Double{
        get{
            1.0/World.zoomScaleToWorld(from: AppState.shared.zoom)
        }
    }
    
    var trackLayerView = TrackLayerView()
    var locationLayerView = LocationLayerView()
    
    override func setupView(){
        hasVerticalScroller = true
        hasHorizontalScroller = true
        addFlippedClipView()
        clipView.drawsBackground = false
        mapWorldView.frame = World.scaledWorld(zoom: AppState.shared.zoom)
        self.documentView = mapWorldView
        mapWorldView.addSubviewFilling(tileLayerView)
        mapWorldView.addSubviewFilling(trackLayerView)
        trackLayerView.isHidden = true
        mapWorldView.addSubviewFilling(locationLayerView)
        locationLayerView.delegate = self
        locationLayerView.dragDelegate = self
        updateLocationLayer()
        locationLayerView.isHidden = !AppState.shared.showLocations
        
        addScrollNotifications()
    }
    
    func updateLocationLayer(){
        locationLayerView.setupMarkers(zoom: AppState.shared.zoom, scale: zoomScale)
    }
    
    func updateTrackLayer(){
        trackLayerView.updateScale(scale: zoomScale)
    }
    
    func showTrack(_ track: Track?){
        if track != nil{
            trackLayerView.updateScale(scale: zoomScale)
        }
        trackLayerView.showTrack(track)
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
        AppState.shared.coordinate = screenCenterCoordinate
        trackLayerView.updateScale(scale: zoomScale)
        mapDelegate?.didScroll()
    }
    
}

extension MapScrollView: DragDelegate{
    
    func mouseDragged(dx: CGFloat, dy: CGFloat){
        scrollBy(dx: -dx, dy: -dy)
        AppState.shared.coordinate = screenCenterCoordinate
        mapDelegate?.didScroll()
    }
    
}

extension MapScrollView: LocationLayerDelegate{
    
    func showLocationDetails(_ location: E5MapData.Location) {
        mapDelegate?.showLocationDetails(location)
    }
    
    func showLocationGroupDetails(_ locationGroup: E5MapData.LocationGroup) {
        mapDelegate?.showLocationGroupDetails(locationGroup)
    }
    
}


