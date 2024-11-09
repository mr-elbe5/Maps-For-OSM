/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit
import CoreLocation

class MenuScrollView: NSView {
    
    let menuView = NSView()
    var fixedView: NSView? = nil
    let scrollView = NSScrollView()
    let contentView = NSView()
    
    override func setupView(){
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
    
    func createFixedView(){
        fixedView = NSView()
    }
    
    func setupMenuView(){
    }
    
    func setupFixedView(){
    }
    
    func setupContentView(){
    }
    
}

