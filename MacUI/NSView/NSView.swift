/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSView{
    
    public var backgroundColor: NSColor? {
        get {
            guard let color = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    public var defaultInset : CGFloat{
        Insets.defaultInset
    }
    
    public var defaultInsets : NSEdgeInsets{
        Insets.defaultInsets
    }
    
    public var smallInset : CGFloat{
        Insets.smallInset
    }
    
    public var smallInsets : NSEdgeInsets{
        Insets.smallInsets
    }
    
    public var doubleInsets : NSEdgeInsets{
        Insets.doubleInsets
    }
    
    public var flatInsets : NSEdgeInsets{
        Insets.flatInsets
    }
    
    public var narrowInsets : NSEdgeInsets{
        Insets.narrowInsets
    }
    
    public var highPriority : Float{
        get{
            900
        }
    }

    public var midPriority : Float{
        get{
            500
        }
    }

    public var lowPriority : Float{
        get{
            300
        }
    }

    public static var defaultPriority : Float{
        get{
            900
        }
    }

    public func setRoundedBorders(){
        if let layer = layer{
            layer.borderWidth = 0.5
            layer.cornerRadius = 5
        }
    }

    public func setGrayRoundedBorders(){
        if let layer = layer{
            layer.borderColor = NSColor.lightGray.cgColor
            layer.borderWidth = 0.5
            layer.cornerRadius = 10
        }
    }

    public func resetConstraints(){
        for constraint in constraints{
            constraint.isActive = false
        }
    }

    public func fillSuperview(insets: NSEdgeInsets = NSEdgeInsets()){
        if let sv = superview{
            fillView(view: sv, insets: insets)
        }
    }
    
    public func fillSafeAreaOf(view: NSView, insets: NSEdgeInsets = NSEdgeInsets()){
        setAnchors(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, insets: insets)
    }

    public func fillView(view: NSView, insets: NSEdgeInsets = NSEdgeInsets()){
        enableAnchors()
            .leading(view.leadingAnchor,inset: insets.left)
            .top(view.topAnchor,inset: insets.top)
            .trailing(view.trailingAnchor,inset: insets.right)
            .bottom(view.bottomAnchor,inset: insets.bottom)
    }

    @discardableResult
    public func setAnchors(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, insets: NSEdgeInsets = NSEdgeInsets()) -> NSView{
        return enableAnchors()
            .top(top, inset: insets.top)
            .leading(leading, inset: insets.left)
            .trailing(trailing, inset: insets.right)
            .bottom(bottom, inset: insets.bottom)
    }

    @discardableResult
    public func setAnchors(centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) -> NSView{
        enableAnchors()
            .centerX(centerX)
            .centerY(centerY)
    }
    
    @discardableResult
    public func addSubviewWithAnchors(_ subview: NSView, top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, insets: NSEdgeInsets = NSEdgeInsets()) -> NSView{
        addSubview(subview)
        subview.setAnchors(top: top, leading: leading, trailing: trailing, bottom: bottom, insets: insets)
        return subview
    }
    
    @discardableResult
    public func addSubviewCentered(_ subview: NSView, centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) -> NSView{
        addSubview(subview)
        subview.setAnchors(centerX: centerX,centerY: centerY)
        return subview
    }
    
    @discardableResult
    public func addSubviewFilling(_ subview: NSView, insets: NSEdgeInsets = NSEdgeInsets()) -> NSView{
        addSubview(subview)
        subview.fillView(view: self, insets: insets)
        return subview
    }
    
    @discardableResult
    public func addSubviewFillingSafeArea(_ subview: NSView, insets: NSEdgeInsets = NSEdgeInsets()) -> NSView{
        addSubview(subview)
        subview.fillSafeAreaOf(view: self, insets: insets)
        return subview
    }
    
    @discardableResult
    public func enableAnchors() -> NSView{
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult
    public func leading(_ anchor: NSLayoutXAxisAnchor?, inset: CGFloat = 0,priority: Float = defaultPriority) -> NSView{
        if let anchor = anchor{
            let constraint = leadingAnchor.constraint(equalTo: anchor, constant: inset)
            if priority != 0{
                constraint.priority = NSLayoutConstraint.Priority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    public func trailing(_ anchor: NSLayoutXAxisAnchor?, inset: CGFloat = 0,priority: Float = defaultPriority) -> NSView{
        if let anchor = anchor{
            let constraint = trailingAnchor.constraint(equalTo: anchor, constant: -inset)
            if priority != 0{
                constraint.priority = NSLayoutConstraint.Priority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    public func top(_ anchor: NSLayoutYAxisAnchor?, inset: CGFloat = 0,priority: Float = defaultPriority) -> NSView{
        if let anchor = anchor{
            let constraint = topAnchor.constraint(equalTo: anchor, constant: inset)
            if priority != 0{
                constraint.priority = NSLayoutConstraint.Priority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    public func bottom(_ anchor: NSLayoutYAxisAnchor?, inset: CGFloat = 0,priority: Float = defaultPriority) -> NSView{
        if let anchor = anchor{
            let constraint = bottomAnchor.constraint(equalTo: anchor, constant: -inset)
            if priority != 0{
                constraint.priority = NSLayoutConstraint.Priority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    public func centerX(_ anchor: NSLayoutXAxisAnchor?,priority: Float = defaultPriority) -> NSView{
        if anchor != nil{
            let constraint = centerXAnchor.constraint(equalTo: anchor!)
            if priority != 0{
                constraint.priority = NSLayoutConstraint.Priority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    public func centerY(_ anchor: NSLayoutYAxisAnchor?,priority: Float = defaultPriority) -> NSView{
        if anchor != nil{
            let constraint = centerYAnchor.constraint(equalTo: anchor!)
            if priority != 0{
                constraint.priority = NSLayoutConstraint.Priority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    public func width(_ width: CGFloat, inset: CGFloat = 0,priority: Float = defaultPriority) -> NSView{
        widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
    
    @discardableResult
    public func width(_ anchor: NSLayoutDimension, inset: CGFloat = 0,priority: Float = defaultPriority) -> NSView{
        widthAnchor.constraint(equalTo: anchor, constant: inset) .isActive = true
        return self
    }
    
    @discardableResult
    public func height(_ height: CGFloat,priority: Float = defaultPriority) -> NSView{
        heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
    
    @discardableResult
    public func height(_ anchor: NSLayoutDimension, inset: CGFloat = 0,priority: Float = defaultPriority) -> NSView{
        heightAnchor.constraint(equalTo: anchor, constant: inset) .isActive = true
        return self
    }
    
    @discardableResult
    public func setSquareByWidth(priority: Float = defaultPriority) -> NSView{
        let c = NSLayoutConstraint(item: self, attribute: .width,
                                   relatedBy: .equal,
                                   toItem: self, attribute: .height,
                                   multiplier: 1, constant: 0)
        c.priority = NSLayoutConstraint.Priority(priority)
        addConstraint(c)
        return self
    }
    
    @discardableResult
    public func setSquareByHeight(priority: Float = defaultPriority) -> NSView{
        let c = NSLayoutConstraint(item: self, attribute: .height,
                                   relatedBy: .equal,
                                   toItem: self, attribute: .width,
                                   multiplier: 1, constant: 0)
        c.priority = NSLayoutConstraint.Priority(priority)
        addConstraint(c)
        return self
    }
    
    @discardableResult
    public func compressable() -> NSView{
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return self
    }
    
    @discardableResult
    public func removeAllConstraints() -> NSView{
        for constraint in constraints{
            removeConstraint(constraint)
        }
        return self
    }

    public func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }

    public func removeSubview(_ view : NSView) {
        for subview in subviews {
            if subview == view{
                subview.removeFromSuperview()
                break
            }
        }
    }
    
    @objc open func setupView(){
    }

}

open class FlippedView: NSView{
    
    override public var isFlipped: Bool {
        return true
    }
    
}

