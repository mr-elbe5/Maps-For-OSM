/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import CoreLocation
import E5Data

import E5MapData

enum MainViewType: Int{
    case map
    case grid
    case presenter
}

class MainViewController: ViewController {
    
    static var instance: MainViewController{
        get{
            MainWindowController.instance.mainViewController
        }
    }
    
    var mainMenu = MainMenuView()
    var mapSplitView: SplitView!
    var mapView = MapView()
    var mapDetailView = MapDetailView()
    var imageGridView = ImageGridView()
    var mediaPresenterView = MediaPresenterView()
    
    var viewType: MainViewType = .map
    
    var currentView: NSView{
        switch viewType{
        case .map:
            return mapSplitView
        case.grid:
            return imageGridView
        case.presenter:
            return mediaPresenterView
        }
    }
    
    override func loadView(){
        view = NSView()
        view.backgroundColor = .black
        view.addSubviewWithAnchors(mainMenu, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        mainMenu.setupView()
        mainMenu.delegate = self
        mapView.setupView()
        mapView.delegate = self
        mapSplitView = SplitView(mainView: mapView, sideView: mapDetailView)
        mapSplitView.minSideWidth = 300
        mapSplitView.setupView()
        view.addSubviewWithAnchors(mapSplitView, top: mainMenu.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor)
        imageGridView.setupView()
        view.addSubview(imageGridView)
        imageGridView.setAnchors(top: mainMenu.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor)
        imageGridView.isHidden = true
        mediaPresenterView.setupView()
        view.addSubview(mediaPresenterView)
        mediaPresenterView.setAnchors(top: mainMenu.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor)
        mediaPresenterView.isHidden = true
        mainMenu.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        mapView.setDefaultLocation()
        mapView.updateLocations()
    }
    
    func openHelp() {
        let controller = HelpViewController()
        ModalWindow.run(title: "help".localize(), viewController: controller, outerWindow: self.view.window!, minSize: CGSize(width: 300, height: 200))
    }
    
    func updateLocations(){
        mapView.updateLocations()
    }
    
}





