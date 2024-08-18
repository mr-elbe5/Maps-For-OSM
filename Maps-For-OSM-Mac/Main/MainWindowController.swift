/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit


class MainWindowController: NSWindowController {
    
    static var windowId = "mapsForOSMMainWindow"
    
    static var defaultSize: NSSize = NSMakeSize(1200, 800)
    static var defaultRect: NSRect{
        var x : CGFloat = 0
        var y : CGFloat = 0
        if let screen = NSScreen.main{
            x = screen.frame.width/2 - defaultSize.width/2
            y = screen.frame.height/2 - defaultSize.height/2
        }
        return NSMakeRect(x, y, defaultSize.width, defaultSize.height)
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
        self.window?.delegate = self
        contentViewController = MainViewController()
        self.window?.setFrameUsingName(MainWindowController.windowId)
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


