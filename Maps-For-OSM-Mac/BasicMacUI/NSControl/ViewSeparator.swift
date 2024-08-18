/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

public protocol ViewSeparatorDelegate{
    func dragged(by dx: CGFloat)
}

open class ViewSeparator: NSControl{
    
    var trackingArea: NSTrackingArea? = nil
    
    var delegate: ViewSeparatorDelegate? = nil
    
    public init(){
        super.init(frame: .zero)
        backgroundColor = .darkGray
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func resetCursorRects(){
        addCursorRect(visibleRect, cursor: NSCursor.resizeLeftRight)
    }
    
    override public func mouseDragged(with event: NSEvent) {
        if event.type == .leftMouseDragged{
            delegate?.dragged(by: event.deltaX)
        }
    }
    
    func clearTrackingAreas() {
        if let trackingArea = trackingArea { removeTrackingArea(trackingArea) }
        trackingArea = nil
    }
    
    override public func updateTrackingAreas() {
        clearTrackingAreas()
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }
    
    override public func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { clearTrackingAreas() }
        else { updateTrackingAreas() }
    }
    
    override public func mouseEntered(with event: NSEvent) { updateCursor(with: event) }
    override public func mouseExited(with event: NSEvent)  { updateCursor(with: event) }
    override public func mouseMoved(with event: NSEvent)   { updateCursor(with: event) }
    override public func cursorUpdate(with event: NSEvent) {}
    
    open func updateCursor(with event: NSEvent) {
        let p = convert(event.locationInWindow, from: nil)
        if bounds.contains(p) {
            NSCursor.resizeLeftRight.set()
        } else {
            NSCursor.arrow.set()
        }
    }
    
}
