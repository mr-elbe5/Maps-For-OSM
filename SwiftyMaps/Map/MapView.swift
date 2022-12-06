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
    var placeLayerView = LocationLayerView()
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
        addSubviewFilling(scrollView)
        scrollView.mapDelegate = self
    }
    
    func setupTrackLayerView(){
        trackLayerView.backgroundColor = .clear
        addSubviewFilling(trackLayerView)
    }
    
    func setupPlaceLayerView(){
        addSubviewFilling(placeLayerView)
        placeLayerView.isHidden = !AppState.instance.showPins
    }
    
    func setupUserLocationView(){
        userLocationView.backgroundColor = .clear
        addSubviewFilling(userLocationView)
    }
    
    func setupControlLayerView(){
        addSubviewFilling(controlLayerView)
        controlLayerView.setup()
    }

    func clearTiles(){
        scrollView.tileLayerView.tileLayer.setNeedsDisplay()
    }
    
    func updatePlaceLayer(){
        placeLayerView.setupMarkers(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func scaleTo(scale: Double, animated : Bool = false){
        scrollView.setZoomScale(scale, animated: animated)
    }
    
    func zoomTo(zoom: Int, animated: Bool){
        scaleTo(scale: World.zoomScale(from: World.maxZoom, to: zoom), animated: animated)
        self.zoom = zoom
        updatePlaceLayer()
    }
    
    func setRegion(region: CoordinateRegion){
        scrollView.scrollToScreenCenter(coordinate: region.center)
        //todo
        //scrollView.setZoomScale(World.getZoomScaleToFit(region: region, scaledBounds: bounds), animated: true)
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
            trackLayerView.setNeedsDisplay()
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
        placeLayerView.setupMarkers(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
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





