/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol MapPositionDelegate{
    func showDetailsOfCurrentPosition()
    func addLocationAtCurrentPosition()
    func addPhotoAtCurrentPosition()
    func addImageAtCurrentPosition()
    func addVideoAtCurrentPosition()
    func addAudioAtCurrentPosition()
    func showDetailsOfCrossPosition()
    func addLocationAtCrossPosition()
    func addImageAtCrossPosition()
}

class MapView: UIView {
    
    var scrollView : MapScrollView!
    var trackLayerView = TrackLayerView()
    var locationLayerView = LocationLayerView()
    var userLocationView = UserLocationView(frame: UserLocationView.frameRect)
    var crossView = UIButton().asIconButton("plus.circle", color: .systemBlue)
    
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
    
    func setupLocationLayerView(){
        addSubviewFilling(locationLayerView)
        locationLayerView.isHidden = !AppState.shared.showLocations
    }
    
    func setupUserLocationView(){
        userLocationView.backgroundColor = .clear
        addSubview(userLocationView)
        userLocationView.menu = getUserLocationMenu()
        userLocationView.showsMenuAsPrimaryAction = true
    }
    
    func getUserLocationMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showDetails".localize()){ action in
            self.delegate?.showDetailsOfCurrentPosition()
        })
        actions.append(UIAction(title: "addLocation".localize()){ action in
            self.delegate?.addLocationAtCurrentPosition()
        })
        actions.append(UIAction(title: "addPhoto".localize()){ action in
            self.delegate?.addPhotoAtCurrentPosition()
        })
        actions.append(UIAction(title: "addImage".localize()){ action in
            self.delegate?.addImageAtCurrentPosition()
        })
        actions.append(UIAction(title: "addVideo".localize()){ action in
            self.delegate?.addVideoAtCurrentPosition()
        })
        actions.append(UIAction(title: "addAudio".localize()){ action in
            self.delegate?.addAudioAtCurrentPosition()
        })
        return UIMenu(title: "currentPosition".localize(), children: actions)
    }
    
    func setupCrossView(){
        addSubviewCentered(crossView, centerX: centerXAnchor, centerY: centerYAnchor)
        crossView.menu = getCrossMenu()
        crossView.showsMenuAsPrimaryAction = true
        crossView.isHidden = !AppState.shared.showCross
    }
    
    func getCrossMenu() -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showDetails".localize()){ action in
            self.delegate?.showDetailsOfCrossPosition()
        })
        actions.append(UIAction(title: "addLocation".localize()){ action in
            self.delegate?.addLocationAtCrossPosition()
        })
        actions.append(UIAction(title: "addImage".localize()){ action in
            self.delegate?.addImageAtCrossPosition()
        })
        return UIMenu(title: "crossPosition".localize(), children: actions)
    }

    func clearTiles(){
        scrollView.tileLayerView.tileLayer.setNeedsDisplay()
    }
    
    func updateLocationLayer(){
        locationLayerView.setupMarkers(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func scaleTo(scale: Double, animated : Bool = false){
        scrollView.setZoomScale(scale, animated: animated)
    }
    
    func zoomTo(zoom: Int, animated: Bool){
        scaleTo(scale: World.zoomScale(from: World.maxZoom, to: zoom), animated: animated)
        self.zoom = zoom
        updateLocationLayer()
    }
    
    func setRegion(region: CoordinateRegion){
        scrollView.scrollToScreenCenter(coordinate: region.center)
        scrollView.setZoomScale(World.getZoomScaleToFit(region: region, scaledBounds: bounds), animated: true)
    }
    
    func setDefaultLocation(){
        scaleTo(scale: AppState.shared.scale)
        Log.info("moving to \(AppState.shared.coordinate.shortString)")
        scrollView.scrollToScreenCenter(coordinate: AppState.shared.coordinate)
        updateLocationLayer()
    }
    
    func locationDidChange(location: CLLocation) {
        userLocationView.updateLocationPoint(planetPoint: MapPoint(location.coordinate).cgPoint, accuracy: location.horizontalAccuracy, offset: contentOffset, scale: scrollView.zoomScale)
    }
    
    func focusUserLocation() {
        if let location = LocationService.shared.location{
            scrollView.scrollToScreenCenter(coordinate: location.coordinate)
        }
    }
    
    func setDirection(_ direction: CLLocationDirection) {
        userLocationView.updateDirection(direction: direction)
    }
    
    func updatePosition(){
        AppState.shared.scale = scrollView.zoomScale
        AppState.shared.coordinate = scrollView.screenCenterCoordinate
    }
    
    func refresh(){
        scrollView.tileLayerView.refresh()
    }
    
}

extension MapView : MapScrollViewDelegate{
    
    func didScroll() {
        assertCenteredContent(scrollView: scrollView)
        updatePosition()
        userLocationView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        locationLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        trackLayerView.updatePosition(offset: contentOffset, scale: scrollView.zoomScale)
        //TestCenter.testMapView(mapView: self)
    }
    
    func didZoom() {
        updatePosition()
    }
    
    func didChangeZoom() {
        locationLayerView.setupMarkers(zoom: zoom, offset: contentOffset, scale: scrollView.zoomScale)
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





