/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import CoreLocation
import E5Data


extension MainViewController: MainMenuDelegate{
    
    func setView(_ type: MainViewType){
        switch type{
        case .map:
            mapSplitView.isHidden = false
            imageGridView.isHidden = true
            mediaPresenterView.isHidden = true
        case .grid:
            mapSplitView.isHidden = true
            imageGridView.isHidden = false
            mediaPresenterView.isHidden = true
        case .presenter:
            mapSplitView.isHidden = true
            imageGridView.isHidden = true
            mediaPresenterView.isHidden = false
        }
        viewType = type
        mainMenu.centerMenu.selectedSegment = type.rawValue
    }
    
    func openICloud() {
        let controller = ICloudViewController()
        ModalWindow.run(title: "iCloud".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200))
    }
    
    func openPreferences() {
        let controller = PreferencesViewController()
        ModalWindow.run(title: "preferences".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 200, height: 100))
    }
    
    func openTiles() {
        let controller = TilesViewController()
        ModalWindow.run(title: "tiles".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200))
    }
    
    func openBackup() {
        let controller = BackupViewController()
        ModalWindow.run(title: "backup".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200))
    }
    
}




