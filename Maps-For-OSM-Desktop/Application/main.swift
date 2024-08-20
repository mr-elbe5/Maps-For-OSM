/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

let app = NSApplication.shared
//app.appearance = NSAppearance(named: .darkAqua)
NSApp.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
