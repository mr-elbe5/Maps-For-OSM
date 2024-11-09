/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit


class HelpViewController: NSTabViewController, ModalResponder {
    
    var generalViewController = GeneralHelpViewController()
    var mapViewController = MapHelpViewController()
    var gridViewController = GridHelpViewController()
    var imageViewController = ImageHelpViewController()
    
    var responseCode: NSApplication.ModalResponse = .cancel
    
    override func loadView() {
        super.loadView()
        let generalHelpItem = NSTabViewItem(viewController: generalViewController)
        generalHelpItem.label = "helpGeneral".localize()
        addTabViewItem(generalHelpItem)
        let mapHelpItem = NSTabViewItem(viewController: mapViewController)
        mapHelpItem.label = "helpMap".localize()
        addTabViewItem(mapHelpItem)
        let gridHelpItem = NSTabViewItem(viewController: gridViewController)
        gridHelpItem.label = "helpGrid".localize()
        addTabViewItem(gridHelpItem)
        let imageHelpItem = NSTabViewItem(viewController: imageViewController)
        imageHelpItem.label = "helpPresenter".localize()
        addTabViewItem(imageHelpItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

class GeneralHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpGeneralText".localize())
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubview(field)
        field.fillSuperview(insets: defaultInsets)
    }
    
}

class MapHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpMapText".localize())
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubview(field)
        field.fillSuperview(insets: defaultInsets)
    }
    
}

class GridHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpGridText".localize())
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubview(field)
        field.fillSuperview(insets: defaultInsets)
    }
    
}

class ImageHelpViewController: NSViewController{
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let font = NSFont.systemFont(ofSize: 14)
        let field = NSTextField(wrappingLabelWithString: "helpPresenterText".localize())
        field.lineBreakMode = .byWordWrapping
        field.font = font
        view.addSubview(field)
        field.fillSuperview(insets: defaultInsets)
    }
    
}
