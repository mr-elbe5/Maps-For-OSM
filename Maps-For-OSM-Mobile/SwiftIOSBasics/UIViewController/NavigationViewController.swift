/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

extension UINavigationController {
    
    var previousViewController: UIViewController? {
       viewControllers.count > 1 ? viewControllers[viewControllers.count - 2] : nil
    }
    
    var rootViewController: UIViewController? {
       viewControllers.count > 0 ? viewControllers[0] : nil
    }
    
}
