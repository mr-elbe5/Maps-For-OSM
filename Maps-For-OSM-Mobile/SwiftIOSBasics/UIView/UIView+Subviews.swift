/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

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
    
    @discardableResult
    func addSubviewAtTop(_ subview: UIView, topView: UIView? = nil, insets: UIEdgeInsets = Insets.defaultInsets) -> UIView{
        addSubview(subview)
        subview.setAnchors(top: topView?.bottomAnchor ?? topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewAtTopCentered(_ subview: UIView, topView: UIView? = nil, insets: UIEdgeInsets = Insets.defaultInsets) -> UIView{
        addSubview(subview)
        subview.setAnchors(top: topView?.bottomAnchor ?? topAnchor, insets: insets)
            .centerX(centerXAnchor)
        return subview
    }
    
    @discardableResult
    func addSubviewAtLeft(_ subview: UIView, leadingView: UIView? = nil, insets: UIEdgeInsets = Insets.defaultInsets) -> UIView{
        addSubview(subview)
        subview.setAnchors(top: topAnchor, leading: leadingView?.trailingAnchor ?? leadingAnchor, bottom: bottomAnchor, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewAtRight(_ subview: UIView, trailingView: UIView? = nil, insets: UIEdgeInsets = Insets.defaultInsets) -> UIView{
        addSubview(subview)
        subview.setAnchors(top: topAnchor, trailing: trailingView?.leadingAnchor ?? trailingAnchor, bottom: bottomAnchor, insets: insets)
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

