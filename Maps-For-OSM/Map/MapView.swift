/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import CommonBasics
import IOSBasics

protocol MapPositionDelegate{
    func showCrossLocationMenu()
}

class MapView: UIView {
    
    var scrollView : MapScrollView!
    var trackLayerView = TrackLayerView()
    var placeLayerView = PlaceLayerView()
    var currentLocationView = CurrentLocationView(frame: CurrentLocationView.frameRect)
    var crossLocationView = UIButton().asIconButton("plus.circle", color: .systemBlue)
    
    var delegate: MapPositionDelegate? = nil
    
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
    
    func setupPlaceLayerView(controller: PlaceLayerDelegate){
        addSubviewFilling(placeLayerView)
        placeLayerView.delegate = controller
        updatePlaces()
        placeLayerView.isHidden = !AppState.shared.showLocations
    }
    
    func setupCurrentLocationView(){
        currentLocationView.backgroundColor = .clear
        addSubview(currentLocationView)
    }
    
    func setupCrossView(){
        crossLocationView.addAction(UIAction(){ action in
            self.delegate?.showCrossLocationMenu()
        }, for: .touchDown)
        addSubviewCentered(crossLocationView, centerX: centerXAnchor, centerY: centerYAnchor)
        crossLocationView.isHidden = !AppState.shared.showCross
    }

    func clearTiles(){
        scrollView.tileLayerView.tileLayer.setNeedsDisplay()
    }
    
    func updatePlaces(){
        placeLayerView.updatePlaces()
        updatePlaceLayer()
    }
    
    func updatePlace(for place: Place){
        placeLayerView.updateMarker(for: place)
    }
    
    func updatePlaceLayer(){
        placeLayerView.setupMarkers(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func scaleTo(scale: Double, animated : Bool = false){
        scrollView.setZoomScale(scale, animated: animated)
        scrollView.setZoomFromScale(scale: scale)
    }
    
    func zoomTo(zoom: Int, animated: Bool){
        scaleTo(scale: World.zoomScale(from: World.maxZoom, to: zoom), animated: animated)
        self.zoom = zoom
        placeLayerView.setupMarkers(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func setRegion(region: CoordinateRegion){
        scrollView.setZoomScale(World.getZoomScaleToFit(region: region, scaledBounds: bounds), animated: true)
        scrollToScreenCenter(coordinate: region.center)
    }
    
    func setDefaultLocation(){
        scaleTo(scale: AppState.shared.scale)
        Log.info("moving to \(AppState.shared.coordinate.shortString)")
        scrollToScreenCenter(coordinate: AppState.shared.coordinate)
        updatePlaceLayer()
    }
    
    func locationDidChange(location: CLLocation) {
        currentLocationView.updateLocationPoint(planetPoint: CGPoint(location.coordinate), accuracy: location.horizontalAccuracy, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func focusUserLocation() {
        if let location = LocationService.shared.location{
            scrollView.scrollToScreenCenter(coordinate: location.coordinate)
        }
    }
    
    func scrollToScreenCenter(coordinate: CLLocationCoordinate2D){
        scrollView.scrollToScreenCenter(coordinate: coordinate)
        updatePosition()
    }
    
    func setDirection(_ direction: CLLocationDirection) {
        currentLocationView.updateDirection(direction: direction)
    }
    
    func updatePosition(){
        AppState.shared.scale = scrollView.zoomScale
        AppState.shared.coordinate = scrollView.screenCenterCoordinate
        AppState.shared.save()
    }
    
    func refresh(){
        scrollView.tileLayerView.refresh()
    }
    
}

extension MapView : MapScrollViewDelegate{
    
    func didScroll() {
        assertCenteredContent(scrollView: scrollView)
        updatePosition()
        currentLocationView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        placeLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func didZoom() {
        updatePosition()
    }
    
    func didChangeZoom() {
        placeLayerView.setupMarkers(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
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






