/*
 My Private Track
 App for creating a diary with entry based on time and map location using text, photos, audios and videos
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

extension UIView{
    
    @discardableResult
    func addSubviewWithAnchors(_ subview: UIView, top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, insets: UIEdgeInsets = .zero) -> UIView{
        addSubview(subview)
        subview.setAnchors(top: top, leading: leading, trailing: trailing, bottom: bottom, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewCentered(_ subview: UIView, centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) -> UIView{
        addSubview(subview)
        subview.setAnchors(centerX: centerX,centerY: centerY)
        return subview
    }
    
    @discardableResult
    func addSubviewFilling(_ subview: UIView, insets: UIEdgeInsets = .zero) -> UIView{
        addSubview(subview)
        subview.fillView(view: self, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewFillingSafeArea(_ subview: UIView, insets: UIEdgeInsets = .zero) -> UIView{
        addSubview(subview)
        subview.fillSafeAreaOf(view: self, insets: insets)
        return subview
    }
    
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func removeSubview(_ view : UIView) {
        for subview in subviews {
            if subview == view{
                subview.removeFromSuperview()
                break
            }
        }
    }

}

