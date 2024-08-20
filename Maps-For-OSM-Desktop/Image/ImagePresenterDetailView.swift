/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

//todo image presenter detail
class ImagePresenterDetailView: NSView {
    
    static func maxImageWidth(outerWidth: CGFloat)-> CGFloat{
        outerWidth - 300
    }
    
    let scrollView = NSScrollView()
    let contentView = NSView()
    
    override func setupView(){
        addSubview(scrollView)
        setupScrollView()
        scrollView.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    func setupMenuView(){
    }
    
    func setupScrollView(){
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.addFlippedClipView()
        scrollView.clipView .drawsBackground = false
        scrollView.documentView = contentView
        setupContentView()
    }
    
    func setupContentView(){
        //todo
    }
    
}

