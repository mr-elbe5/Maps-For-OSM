/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIViewController{
    
    var isDarkMode: Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }
    
    func showAlert(title: String, text: String, onOk: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(table: "Base"),style: .default) { action in
            onOk?()
        })
        self.present(alertController, animated: true)
    }
    
    func showDestructiveApprove(title: String, text: String, onApprove: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "yes".localize(table: "Base"), style: .destructive) { action in
            onApprove?()
        })
        alertController.addAction(UIAlertAction(title: "no".localize(table: "Base"), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func showApprove(title: String, text: String, onApprove: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "yes".localize(table: "Base"), style: .default) { action in
            onApprove?()
        })
        alertController.addAction(UIAlertAction(title: "no".localize(table: "Base"), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func showDone(title: String, text: String){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(table: "Base"), style: .default))
        self.present(alertController, animated: true)
    }
    
    func showError(_ reason: String){
        showAlert(title: "error".localize(table: "Base"), text: reason.localize())
    }
    
}

