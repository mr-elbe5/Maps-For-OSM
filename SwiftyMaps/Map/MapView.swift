/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class MapView: UIView {
    
    var scrollView : MapScrollView!
    var trackLayerView = TrackLayerView()
    var locationLayerView = PlaceLayerView()
    var userLocationView = UserLocationView()
    var controlLayerView = ControlLayerView()
    
    var zoom: Int{
        get{scrollView.zoom}
        set{scrollView.zoom = newValue}
    }
    
    var position : MapPosition? = MapPosition.loadPosition()
    var startLocationIsSet = false
    
    var contentOffset : CGPoint{
        scrollView.contentOffset
    }
    
    func setupScrollView(){
        scrollView = MapScrollView(frame: bounds)
        addSubview(scrollView)
        scrollView.fillView(view: self)
        scrollView.mapDelegate = self
    }
    
    func setupTrackLayerView(){
        trackLayerView.backgroundColor = .clear
        addSubview(trackLayerView)
        trackLayerView.fillView(view: self)
    }
    
    func setupLocationLayerView(){
        addSubview(locationLayerView)
        locationLayerView.fillView(view: self)
        locationLayerView.isHidden = !Preferences.instance.showPins
    }
    
    func setupUserLocationView(){
        userLocationView.backgroundColor = .clear
        addSubview(userLocationView)
        userLocationView.fillView(view: self)
    }
    
    func setupControlLayerView(){
        addSubview(controlLayerView)
        controlLayerView.fillView(view: self)
        controlLayerView.setup()
    }

    func clearTiles(){
        scrollView.tileLayerView.tileLayer.setNeedsDisplay()
    }
    
    func clearTrack(_ track: TrackData? = nil){
        if track == nil || trackLayerView.track == track{
            trackLayerView.setTrack(track: nil)
            controlLayerView.stopTrackControl()
        }
    }
    
    func updateLocationLayer(){
        locationLayerView.setupPins(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func scaleTo(scale: Double, animated : Bool = false){
        scrollView.setZoomScale(scale, animated: animated)
    }
    
    func zoomTo(zoom: Int, animated: Bool){
        scaleTo(scale: World.zoomScale(from: World.maxZoom, to: zoom), animated: animated)
        self.zoom = zoom
        updateLocationLayer()
    }
    
    func setDefaultLocation(){
        if Preferences.instance.startWithLastPosition, let pos = position{
            Log.log("Setting location to last position")
            scaleTo(scale: pos.scale)
            updateLocationLayer()
            scrollView.scrollToScreenCenter(coordinate: pos.coordinate)
            startLocationIsSet = true
        }
        else{
            Log.log("Setting location to default position, zooming to min zoom")
            zoomTo(zoom: World.minZoom, animated: false)
            scrollView.scrollToScreenCenter(coordinate: World.startCoordinate)
            updateLocationLayer()
        }
    }
    
    func locationDidChange(location: CLLocation) {
        if !startLocationIsSet{
            Log.log("Start location not set, zooming to min zoom")
            zoomTo(zoom: World.minZoom, animated: false)
            scrollView.scrollToScreenCenter(coordinate: location.coordinate)
            updatePosition()
            startLocationIsSet = true
        }
        else{
            userLocationView.updateLocationPoint(planetPoint: World.planetPointFromCoordinate(coordinate: location.coordinate), accuracy: location.horizontalAccuracy, offset: contentOffset, scale: scrollView.zoomScale)
            if ActiveTrack.isTracking{
                ActiveTrack.updateTrack(with: location)
                trackLayerView.updateTrack()
                controlLayerView.updateTrackInfo()
            }
        }
    }
    
    func focusUserLocation() {
        if let location = LocationService.shared.lastLocation{
            scrollView.scrollToScreenCenter(coordinate: location.coordinate)
        }
    }
    
    func setDirection(_ direction: CLLocationDirection) {
        userLocationView.updateDirection(direction: direction)
    }
    
    func updatePosition(){
        position = MapPosition(scale: scrollView.zoomScale, coordinate: scrollView.screenCenterCoordinate)
    }
    
    func savePosition(){
        if let pos = position{
            pos.save()
        }
    }
    
}

extension MapView : MapScrollViewDelegate{
    
    func didScroll() {
        assertCenteredContent(scrollView: scrollView)
        updatePosition()
        if startLocationIsSet{
            userLocationView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        }
        locationLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        TestCenter.testMapView(mapView: self)
    }
    
    func didZoom() {
        updatePosition()
    }
    
    func didChangeZoom() {
        locationLayerView.setupPins(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
        TestCenter.testMapView(mapView: self)
    }
    
    // for infinite scroll using 3 * content width
    private func assertCenteredContent(scrollView: UIScrollView){
        if scrollView.contentOffset.x >= 2*scrollView.contentSize.width/3{
            scrollView.contentOffset.x -= scrollView.contentSize.width/3
        }
        else if scrollView.contentOffset.x < scrollView.contentSize.width/3{
            scrollView.contentOffset.x += scrollView.contentSize.width/3
        }
    }
    
}





