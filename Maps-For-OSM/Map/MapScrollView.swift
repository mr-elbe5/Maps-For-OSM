/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import E5Data
import E5IOSUI
import E5MapData
import Maps_For_OSM_Data

protocol MapScrollViewDelegate{
    
    func didScroll()
    func didZoom()
    func didChangeZoom()
    
}

class MapScrollView : UIScrollView{
    
    var zoom : Int = 0
    
    var tileLayerView = TileLayerView()
    
    var mapDelegate: MapScrollViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isScrollEnabled = true
        isDirectionalLockEnabled = false
        isPagingEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bounces = false
        bouncesZoom = false
        maximumZoomScale = 1.0
        minimumZoomScale = World.zoomScale(from: World.maxZoom, to: World.minZoom)
        contentSize = World.scrollableWorldSize
        delegate = self
        tileLayerView.backgroundColor = .white
        addSubview(tileLayerView)
        tileLayerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var visibleMapRect : CGRect{
        //division by zoomScale is upScale
        CGRect(x: bounds.minX/zoomScale, y: bounds.minY/zoomScale, width: bounds.width/zoomScale, height: bounds.height/zoomScale).normalizedRect
    }
    
    var screenCenter : CGPoint{
        CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    var screenCenterMapPoint : CGPoint{
        mapPoint(screenPoint: screenCenter)
    }
    
    var screenCenterCoordinate : CLLocationCoordinate2D{
        screenCenterMapPoint.coordinate
    }
    
    var screenCoordinateSpan : CoordinateSpan{
        let topLeft = coordinate(screenPoint: CGPoint(x: 0, y: 0))
        let bottomRight = coordinate(screenPoint: CGPoint(x: bounds.width, y: bounds.height))
        return CoordinateSpan(latitudeDelta: topLeft.latitude - bottomRight.latitude, longitudeDelta: topLeft.longitude - bottomRight.longitude)
    }
    
    var visibleRegion : CoordinateRegion{
        CoordinateRegion(topLeft: coordinate(screenPoint: CGPoint(x: 0, y: 0)), bottomRight: coordinate(screenPoint: CGPoint(x: visibleSize.width, y: visibleSize.height)))
    }
    
    var tileRegion : TileRegion{
        TileRegion(topLeft: coordinate(screenPoint: CGPoint(x: 0, y: 0)), bottomRight: coordinate(screenPoint: CGPoint(x: visibleSize.width, y: visibleSize.height)), maxZoom: World.maxZoom)
    }
    
    func setZoomFromScale(scale: Double){
        let zoom = World.maxZoom - World.zoomLevelFromScale(scale: 1.0/scale)
        if zoom != self.zoom{
            self.zoom = zoom
        }
    }
    
    func contentPoint(screenPoint: CGPoint) -> CGPoint{
        CGPoint(x: screenPoint.x + contentOffset.x, y: screenPoint.y + contentOffset.y)
    }
    
    func normalizedContentPoint(screenPoint: CGPoint) -> CGPoint{
        CGPoint(x: screenPoint.x + contentOffset.x - contentSize.width/3, y: screenPoint.y + contentOffset.y)
    }
    
    func mapPoint(screenPoint : CGPoint) -> CGPoint{
        //division by zoomScale is upScale
        CGPoint(x: (screenPoint.x + contentOffset.x)/zoomScale, y: (screenPoint.y + contentOffset.y)/zoomScale).normalizedPoint
    }
    
    func coordinate(screenPoint : CGPoint) -> CLLocationCoordinate2D{
        mapPoint(screenPoint: screenPoint).coordinate
    }
    
    func screenPoint(mapPoint: CGPoint) -> CGPoint{
        //multiplication by zoomScale is downScale, shift to middle segment
        CGPoint(x: mapPoint.x*zoomScale - contentOffset.x + contentSize.width/3, y: mapPoint.y*zoomScale - contentOffset.y)
    }
    
    func screenPoint(coordinate: CLLocationCoordinate2D) -> CGPoint{
        screenPoint(mapPoint: CGPoint(coordinate))
    }
    
    func scrollToScreenPoint(coordinate: CLLocationCoordinate2D, screenPoint: CGPoint){
        var x = World.scaledX(coordinate.longitude, downScale: zoomScale) + World.scaledExtent(downScale: zoomScale)
        var y = World.scaledY(coordinate.latitude, downScale: zoomScale)
        x = min(max(0, x - screenPoint.x), contentSize.width - visibleSize.width)
        y = min(max(0, y - screenPoint.y), contentSize.height - visibleSize.height)
        contentOffset = CGPoint(x: x, y: y)
    }
    
    func scrollToScreenCenter(coordinate: CLLocationCoordinate2D){
        scrollToScreenPoint(coordinate: coordinate, screenPoint: screenCenter)
    }
    
}

extension MapScrollView : UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        tileLayerView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        mapDelegate?.didZoom()
        let zoom = World.maxZoom - World.zoomLevelFromScale(scale: 1.0/scale)
        if zoom != self.zoom{
            self.zoom = zoom
            self.mapDelegate?.didChangeZoom()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        assertCenteredContent(scrollView: scrollView)
        mapDelegate?.didScroll()
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

