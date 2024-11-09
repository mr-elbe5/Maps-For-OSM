/*
 E5IOSUI
 Basic classes and extension for IOS
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
    
    func showCancel(title: String, text: String, onCancel: (() -> Void)? = nil) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "cancel".localize(table: "Base"),style: .default) { action in
            onCancel?()
        })
        self.present(alertController, animated: true)
        return alertController
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
    
    func showDecide(title: String, text: String, onYes: @escaping (() -> Void), onNo: @escaping (() -> Void)){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "yes".localize(table: "Base"), style: .default) { action in
            onYes()
        })
        alertController.addAction(UIAlertAction(title: "no".localize(table: "Base"), style: .cancel){ action in
            onNo()
        })
        self.present(alertController, animated: true)
    }
    
    func showDone(title: String, text: String, onApprove: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(table: "Base"), style: .default){ action in
            onApprove?()
        })
        self.present(alertController, animated: true)
    }
    
    func showError(_ reason: String){
        showAlert(title: "error".localize(table: "Base"), text: reason.localize())
    }
    
    func startSpinner() -> UIActivityIndicatorView{
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.setAnchors(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        return spinner
    }
    
    func stopSpinner(_ spinner: UIActivityIndicatorView?) {
        if let spinner = spinner{
            spinner.stopAnimating()
            self.view.removeSubview(spinner)
        }
    }
    
}

