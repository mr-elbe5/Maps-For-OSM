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
    
    var currentMapRegion : MapRegion{
        MapRegion(topLeft: getCoordinate(screenPoint: CGPoint(x: 0, y: 0)), bottomRight: getCoordinate(screenPoint: CGPoint(x: scrollView.visibleSize.width, y: scrollView.visibleSize.height)), maxZoom: MapStatics.maxZoom)
    }
    
    var contentDrawScale : CGFloat{
        scrollView.zoomScale*scrollView.tileLayerView.layer.contentsScale
    }
    
    var contentOffset : CGPoint{
        scrollView.contentOffset
    }
    
    var scrollViewPlanetSize : CGSize{
        CGSize(width: scrollView.contentSize.width/3, height: scrollView.contentSize.height)
    }
    
    func setupScrollView(){
        scrollView = MapScrollView(frame: bounds)
        print("minZoomScale \(scrollView.minimumZoomScale)")
        addSubview(scrollView)
        scrollView.fillView(view: self)
        print("contentSize \(scrollView.contentSize)")
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
    
    func getCoordinate(screenPoint: CGPoint) -> CLLocationCoordinate2D{
        let size = scrollViewPlanetSize
        var point = screenPoint
        while point.x >= size.width{
            point.x -= size.width
        }
        point.x += scrollView.contentOffset.x
        point.y += scrollView.contentOffset.y
        return MapStatics.coordinateFromPointInScaledPlanetSize(point: point, scaledSize: size)
    }
    
    func getPlanetRect() -> CGRect{
        getPlanetRect(screenRect: bounds)
    }
    
    func getPlanetRect(screenRect: CGRect) -> CGRect{
        NormalizedPlanetRect(rect: screenRect.offsetBy(dx: contentOffset.x, dy: contentOffset.y), fromScale: scrollView.zoomScale).rect
    }
    
    func getScreenPoint(coordinate: CLLocationCoordinate2D) -> CGPoint{
        let size = scrollViewPlanetSize
        var xOffset = scrollView.contentOffset.x
        while xOffset > size.width{
            xOffset -= size.width
        }
        var point = MapStatics.pointInScaledSize(coordinate: coordinate, scaledSize: size)
        point.x -= xOffset
        point.y -= scrollView.contentOffset.y
        return point
    }
    
    func scrollToCoordinateAtScreenPoint(coordinate: CLLocationCoordinate2D, point: CGPoint){
        let size = scrollViewPlanetSize
        var x = round((coordinate.longitude + 180)/360.0*size.width) + size.width
        var y = round((1 - log(tan(coordinate.latitude*CGFloat.pi/180.0) + 1/cos(coordinate.latitude*CGFloat.pi/180.0 ))/CGFloat.pi )/2*size.height)
        x = max(0, x - point.x)
        x = min(x, scrollView.contentSize.width - scrollView.visibleSize.width)
        y = max(0, y - point.y)
        y = min(y, scrollView.contentSize.height - scrollView.visibleSize.height)
        scrollView.contentOffset = CGPoint(x: x, y: y)
    }
    
    func scrollToCenteredCoordinate(coordinate: CLLocationCoordinate2D){
        scrollToCoordinateAtScreenPoint(coordinate: coordinate, point: CGPoint(x: scrollView.visibleSize.width/2, y: scrollView.visibleSize.height/2))
    }
    
    func updateLocationLayer(){
        locationLayerView.setupPins(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func scaleTo(scale: Double, animated : Bool = false){
        scrollView.setZoomScale(scale, animated: animated)
    }
    
    func zoomTo(zoom: Int, animated: Bool){
        scaleTo(scale: MapStatics.zoomScale(at: zoom - MapStatics.maxZoom), animated: animated)
        self.zoom = zoom
        updateLocationLayer()
    }
    
    func setDefaultLocation(){
        if Preferences.instance.startWithLastPosition, let pos = position{
            Log.log("Setting location to last position")
            scaleTo(scale: pos.scale)
            updateLocationLayer()
            scrollToCenteredCoordinate(coordinate: pos.coordinate)
            startLocationIsSet = true
        }
        else{
            Log.log("Setting location to default position, zooming to min zoom")
            zoomTo(zoom: MapStatics.minZoom, animated: false)
            scrollToCenteredCoordinate(coordinate: MapStatics.startCoordinate)
            updateLocationLayer()
        }
    }
    
    func locationDidChange(location: CLLocation) {
        if !startLocationIsSet{
            Log.log("Start location not set, zooming to min zoom")
            zoomTo(zoom: MapStatics.minZoom, animated: false)
            scrollToCenteredCoordinate(coordinate: location.coordinate)
            updatePosition()
            startLocationIsSet = true
        }
        else{
            userLocationView.updateLocationPoint(planetPoint: MapStatics.planetPointFromCoordinate(coordinate: location.coordinate), accuracy: location.horizontalAccuracy, offset: contentOffset, scale: scrollView.zoomScale)
            if ActiveTrack.isTracking{
                ActiveTrack.updateTrack(with: location)
                trackLayerView.updateTrack()
                controlLayerView.updateTrackInfo()
            }
        }
    }
    
    func focusUserLocation() {
        if let location = LocationService.shared.lastLocation{
            scrollToCenteredCoordinate(coordinate: location.coordinate)
        }
    }
    
    func setDirection(_ direction: CLLocationDirection) {
        userLocationView.updateDirection(direction: direction)
    }
    
    func getVisibleCenter() -> CGPoint{
        CGPoint(x: scrollView.visibleSize.width/2, y: scrollView.visibleSize.height/2)
    }
    
    func getVisibleCenterCoordinate() -> CLLocationCoordinate2D{
        getCoordinate(screenPoint: getVisibleCenter())
    }
    
    func updatePosition(){
        position = MapPosition(scale: scrollView.zoomScale, coordinate: getVisibleCenterCoordinate())
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
    }
    
    func didZoom() {
        updatePosition()
    }
    
    func didChangeZoom() {
        locationLayerView.setupPins(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
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





