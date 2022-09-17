//
//  MapScrollView.swift
//  SwiftyMaps for OSM
//
//  Created by Michael Rönnau on 16.09.22.
//

import Foundation
import UIKit

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
        minimumZoomScale = World.zoomFactor(fromZoom: World.maxZoom, toZoom: World.minZoom)
        contentSize = World.mapSize.cgSize
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
    
}

extension MapScrollView : UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        tileLayerView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        mapDelegate?.didZoom()
        let zoom = MapStatics.zoomLevelFromReverseScale(scale: scale)
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

