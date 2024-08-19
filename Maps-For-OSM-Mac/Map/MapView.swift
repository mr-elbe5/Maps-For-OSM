/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import E5Data


import UniformTypeIdentifiers

protocol MapViewDelegate{
    //from cross
    func addImage(at coordinate: CLLocationCoordinate2D)
    func addVideo(at coordinate: CLLocationCoordinate2D)
    func addAudio(at coordinate: CLLocationCoordinate2D)
    func addNote(at coordinate: CLLocationCoordinate2D)
    
    //from markers
    func showLocationDetails(_ location: Location)
    func showLocationGroupDetails(_ locationGroup: LocationGroup)
}

class MapView: NSView {
    
    var menuView = MapMenuView()
    var scrollView = MapScrollView()
    var crossLocationView = NSButton().asIconButton("plus.circle", color: .systemBlue)
    
    var delegate: MapViewDelegate? = nil
    
    override func setupView(){
        addSubview(menuView)
        menuView.setupView()
        menuView.setAnchors(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        menuView.delegate = self
        
        scrollView.mapDelegate = self
        addSubview(scrollView)
        scrollView.setupView()
        scrollView.setAnchors(top: topAnchor, leading: menuView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        
        crossLocationView.isBordered = false
        crossLocationView.target = self
        crossLocationView.action = #selector(showCrossLocationMenu)
        addSubviewCentered(crossLocationView, centerX: scrollView.centerXAnchor, centerY: scrollView.centerYAnchor)
        crossLocationView.isHidden = !AppState.shared.showCross
    }
    
    func setDefaultLocation(){
        scrollView.zoomTo(zoom: AppState.shared.zoom, at: AppState.shared.coordinate)
    }
    
    func refresh(){
        scrollView.tileLayerView.refresh()
    }
    
    func updateLocations(){
        scrollView.updateLocationLayer()
    }
    
    func updateTrack(){
        scrollView.updateTrackLayer()
    }
    
    func showLocationOnMap(coordinate: CLLocationCoordinate2D) {
        scrollView.scrollToScreenCenter(coordinate: coordinate)
    }
    
    func showMapRectOnMap(worldRect: CGRect) {
        let viewSize = bounds.scaleBy(0.9).size
        scrollView.zoomTo(zoom: World.getZoomToFit(worldRect: worldRect, scaledSize: viewSize))
        scrollView.scrollToScreenCenter(coordinate: worldRect.centerCoordinate)
        Log.info("scrollZoom = \(AppState.shared.zoom)")
        Log.info("scrollScale = \(scrollView.zoomScale)")
    }
    
    @objc func showCrossLocationMenu(){
        let menu = CrossLocationMenu(mapView: self)
        menu.popover.show(relativeTo: self.crossLocationView.frame, of: self, preferredEdge: .maxY)
    }
                                      
    @objc func addImageAtCross(){
        delegate?.addImage(at: scrollView.screenCenterCoordinate)
    }
    
    @objc func addVideoAtCross(){
        delegate?.addVideo(at: scrollView.screenCenterCoordinate)
    }
    
    @objc func addAudioAtCross(){
        delegate?.addAudio(at: scrollView.screenCenterCoordinate)
    }
    
    @objc func addNoteAtCross(){
        delegate?.addNote(at: scrollView.screenCenterCoordinate)
    }
    
}

extension MapView: MapMenuDelegate{
    
    func zoomIn() {
        scrollView.zoomIn()
    }
    
    func zoomOut() {
        scrollView.zoomOut()
    }
    
    func toggleCross() {
        crossLocationView.isHidden = !crossLocationView.isHidden
    }
    
    func refreshMap() {
        updateLocations()
    }
    
    func hideTrack() {
        scrollView.showTrack(nil)
    }
    
}

extension MapView : MapScrollViewDelegate{
    
    // from markers
    
    func showLocationDetails(_ location: Location) {
        delegate?.showLocationDetails(location)
    }
    
    func showLocationGroupDetails(_ locationGroup: LocationGroup) {
        delegate?.showLocationGroupDetails(locationGroup)
    }
    
    // scroll view
    
    func didScroll() {
        updateLocations()
    }
    
    func didZoom() {
        updateLocations()
        updateTrack()
    }
    
    override func autoscroll(with event: NSEvent) -> Bool {
        scrollView.autoscroll(with: event)
    }
    
}

