/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit


class MainWindowController: NSWindowController {
    
    static var windowId = "mapsForOSMMainWindow"
    
    static var defaultRect: NSRect{
        if let screen = NSScreen.main{
            return NSRect(x: 200, y: 200, width: Int(screen.frame.width) - 400, height: Int(screen.frame.height - 400))
        }
        return NSRect(x: 50, y: 50, width: 1200, height: 800)
    }
    
    static var instance = MainWindowController()
    
    var mainViewController: MainViewController{
        contentViewController as! MainViewController
    }
    
    init(){
        let window = NSWindow(contentRect: MainWindowController.defaultRect, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: true)
        window.title = "Maps For OSM"
        window.minSize = CGSize(width: 800, height: 600)
        super.init(window: window)
        window.delegate = self
        contentViewController = MainViewController()
        if !window.setFrameUsingName(MainWindowController.windowId){
            window.setFrame(MainWindowController.defaultRect, display: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
        
extension MainWindowController: NSWindowDelegate{
    
    func windowWillClose(_ notification: Notification) {
        window?.saveFrame(usingName: MainWindowController.windowId)
        NSApplication.shared.terminate(self)
    }
    
}


