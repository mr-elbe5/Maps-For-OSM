//
//  MapScrollView.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation
import UIKit
import CoreLocation

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
        print("contentSize \(contentSize)")
        delegate = self
        print("scroll min zoom scale = \(minimumZoomScale)")
        tileLayerView.backgroundColor = .white
        addSubview(tileLayerView)
        tileLayerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var visibleMapRect : MapRect{
        //division by zoomScale is upScale
        MapRect(x: bounds.minX/zoomScale, y: bounds.minY/zoomScale, width: bounds.width/zoomScale, height: bounds.height/zoomScale).normalizedRect
    }
    
    var scaledWorldSize : CGSize{
        //scroll size is 3 x wider for infinite scroll
        CGSize(width: contentSize.width/3, height: contentSize.height)
    }
    
    var screenCenter : CGPoint{
        CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    var screenCenterMapPoint : MapPoint{
        mapPoint(screenPoint: screenCenter)
    }
    
    var screenCenterCoordinate : CLLocationCoordinate2D{
        screenCenterMapPoint.coordinate
    }
    
    var screenCoordinateSpan : CoordinateSpan{
        let topLeft = coordinate(screenPoint: CGPoint(x: 0, y: 0))
        let bottomRight = coordinate(screenPoint: CGPoint(x: bounds.width, y: bounds.height))
        //todo
        return CoordinateSpan(latitudeDelta: topLeft.latitude - bottomRight.latitude, longitudeDelta: topLeft.longitude - bottomRight.longitude)
    }
    
    var tileRegion : TileRegion{
        TileRegion(topLeft: coordinate(screenPoint: CGPoint(x: 0, y: 0)), bottomRight: coordinate(screenPoint: CGPoint(x: visibleSize.width, y: visibleSize.height)), maxZoom: World.maxZoom)
    }
    
    func mapPoint(screenPoint : CGPoint) -> MapPoint{
        //division by zoomScale is upScale
        MapPoint(x: (screenPoint.x + contentOffset.x)/zoomScale, y: (screenPoint.y + contentOffset.y)/zoomScale).normalizedPoint
    }
    
    func coordinate(screenPoint : CGPoint) -> CLLocationCoordinate2D{
        mapPoint(screenPoint: screenPoint).coordinate
    }
    
    func screenPoint(mapPoint: MapPoint) -> CGPoint{
        //multiplication by zoomScale is downScale, shift to middle segment
        CGPoint(x: mapPoint.x*zoomScale - contentOffset.x + contentSize.width/3, y: mapPoint.y*zoomScale - contentOffset.y)
    }
    
    func screenPoint(coordinate: CLLocationCoordinate2D) -> CGPoint{
        screenPoint(mapPoint: MapPoint(coordinate))
    }
    
    func scrollToScreenPoint(coordinate: CLLocationCoordinate2D, screenPoint: CGPoint){
        let size = scaledWorldSize
        var x = round(World.xPos(longitude: coordinate.longitude)*size.width) + size.width
        var y = round(World.yPos(latitude: coordinate.latitude)*size.height)
        x = max(0, x - screenPoint.x)
        x = min(x, contentSize.width - visibleSize.width)
        y = max(0, y - screenPoint.y)
        y = min(y, contentSize.height - visibleSize.height)
        print("old contentOffset = \(CGPoint(x: x, y: y))")
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
