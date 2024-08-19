/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSScrollView{
    
    public var clipView: NSClipView{
        contentView
    }
    
    public var contentRect: CGRect{
        clipView.documentRect
    }
    
    public var contentOffset: CGPoint{
        documentVisibleRect.origin
    }
    
    public var visibleContentRect: CGRect{
        clipView.documentVisibleRect
    }
    
    // positive value!
    public var scrollOrigin: CGPoint{
        documentVisibleRect.origin
    }
    
    public func addFlippedClipView(){
        contentView = FlippedClipView()
        contentView.fillSuperview()
    }
    
    public func addClipView(){
        contentView = NSClipView()
        contentView.fillSuperview()
    }
    
    public var maxScrollX: CGFloat{
        contentRect.width - visibleContentRect.width
    }
    
    public var maxScrollY: CGFloat{
        contentRect.height - visibleContentRect.height
    }
    
    public func getSafeScrollPoint(contentPoint: CGPoint) -> CGPoint{
        CGPoint(x: min(max(0, contentPoint.x - visibleContentRect.width/2), maxScrollX) ,
                                  y: min(max(0, contentPoint.y - visibleContentRect.height/2), maxScrollY))
    }
    
    public func scrollTo(_ scrollPoint: CGPoint){
        scroll(clipView, to: scrollPoint)
    }
    
    public func scrollBy(dx: CGFloat, dy: CGFloat){
        scroll(clipView, to: CGPoint(x: contentOffset.x + dx, y: contentOffset.y + dy))
    }
    
}

final class FlippedClipView: NSClipView {
    
    override public var isFlipped: Bool {
        return true
    }
    
}

extension NSScrollView{
    
    public var screenCenter : CGPoint{
        CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    public func asVerticalScrollView(contentView: NSView, insets : NSEdgeInsets = Insets.defaultInsets){
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = false
        let clipView = FlippedClipView()
        self.contentView = clipView
        self.documentView = contentView
        contentView.setAnchors(top:clipView.topAnchor, leading: clipView.leadingAnchor, trailing: clipView.trailingAnchor)
    }
    
    public func asScrollView(contentView: NSView, insets : NSEdgeInsets = Insets.defaultInsets){
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = true
        let clipView = FlippedClipView()
        self.contentView = clipView
        self.documentView = contentView
        contentView.setAnchors(top:clipView.topAnchor, leading: clipView.leadingAnchor)
    }
    
    public func addScrollNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidScroll),
            name: NSScrollView.didLiveScrollNotification,
            object: self
        )
    }
    
    public func addZoomNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewDidZoom),
            name: NSScrollView.didEndLiveMagnifyNotification,
            object: self
        )
    }
    
    @objc open func scrollViewDidScroll(){
    }
    
    @objc open func scrollViewDidZoom(){
    }
    
}

