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
    var placeLayerView = PlaceLayerView()
    var userLocationView = UserLocationView()
    var controlLayerView = ControlLayerView()
    
    var zoom: Int{
        get{scrollView.zoom}
        set{scrollView.zoom = newValue}
    }
    
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
    
    func setupPlaceLayerView(){
        addSubview(placeLayerView)
        placeLayerView.fillView(view: self)
        placeLayerView.isHidden = !AppState.instance.showPins
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
    
    func updatePlaceLayer(){
        placeLayerView.setupPins(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func scaleTo(scale: Double, animated : Bool = false){
        scrollView.setZoomScale(scale, animated: animated)
    }
    
    func zoomTo(zoom: Int, animated: Bool){
        scaleTo(scale: World.zoomScale(from: World.maxZoom, to: zoom), animated: animated)
        self.zoom = zoom
        updatePlaceLayer()
    }
    
    func setDefaultLocation(){
        scaleTo(scale: AppState.instance.scale)
        scrollView.scrollToScreenCenter(coordinate: AppState.instance.coordinate)
        updatePlaceLayer()
    }
    
    func locationDidChange(location: CLLocation) {
        userLocationView.updateLocationPoint(planetPoint: MapPoint(location.coordinate).cgPoint, accuracy: location.horizontalAccuracy, offset: contentOffset, scale: scrollView.zoomScale)
        if TrackRecorder.isRecording{
            TrackRecorder.updateTrack(with: location)
            trackLayerView.redrawTrack()
            controlLayerView.updateTrackInfo()
        }
    }
    
    func focusUserLocation() {
        if let location = LocationService.instance.location{
            scrollView.scrollToScreenCenter(coordinate: location.coordinate)
        }
    }
    
    func setDirection(_ direction: CLLocationDirection) {
        userLocationView.updateDirection(direction: direction)
    }
    
    func updatePosition(){
        AppState.instance.scale = scrollView.zoomScale
        AppState.instance.coordinate = scrollView.screenCenterCoordinate
    }
    
    func savePosition(){
        AppState.instance.save()
    }
    
}

extension MapView : MapScrollViewDelegate{
    
    func didScroll() {
        assertCenteredContent(scrollView: scrollView)
        updatePosition()
        userLocationView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        placeLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        //TestCenter.testMapView(mapView: self)
    }
    
    func didZoom() {
        updatePosition()
    }
    
    func didChangeZoom() {
        placeLayerView.setupPins(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
        //TestCenter.testMapView(mapView: self)
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





