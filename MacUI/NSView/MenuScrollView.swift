/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit
import CoreLocation

open class MenuScrollView: NSView {
    
    public let menuView = NSView()
    public var fixedView: NSView? = nil
    public let scrollView = NSScrollView()
    public let contentView = NSView()
    
    override open func setupView(){
        addSubview(menuView)
        setupMenuView()
        addSubviewWithAnchors(menuView, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        var lastView: NSView = menuView
        if let fixedView = fixedView{
            addSubviewWithAnchors(fixedView, top: menuView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
            setupFixedView()
            lastView = fixedView
        }
        scrollView.asVerticalScrollView(contentView: contentView, insets: defaultInsets)
        addSubviewWithAnchors(scrollView, top: lastView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        setupContentView()
    }
    
    open func createFixedView(){
        fixedView = NSView()
    }
    
    open func setupMenuView(){
    }
    
    open func setupFixedView(){
    }
    
    open func setupContentView(){
    }
    
}

