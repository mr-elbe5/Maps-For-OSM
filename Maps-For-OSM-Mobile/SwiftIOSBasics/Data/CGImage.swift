/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

extension CGImage {
    func copyContext() -> CGContext? {
        if let ctx = CGContext(
            data: nil,
            width: self.width,
            height: self.height,
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: self.bytesPerRow,
            space: self.colorSpace!,
            bitmapInfo: self.bitmapInfo.rawValue
        ) {
            ctx.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
            return ctx
        } else {
            return nil
        }
    }
}
