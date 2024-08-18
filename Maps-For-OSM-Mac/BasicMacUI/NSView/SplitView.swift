/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

open class SplitView: NSView{
    
    public var mainView: NSView
    public var separator = ViewSeparator()
    public var sideView: NSView
    var sideViewWidthConstraint = NSLayoutConstraint()
    
    public var minSideWidth: CGFloat = 200
    
    open var defaultSideWidth: CGFloat{
        max(minSideWidth, bounds.width / 4)
    }
    
    open var maxSideWidth: CGFloat{
        bounds.width / 2
    }
    
    public init(mainView: NSView, sideView: NSView) {
        self.mainView = mainView
        self.sideView = sideView
        super.init(frame: .zero)
        self.sideViewWidthConstraint = sideView.widthAnchor.constraint(equalToConstant: minSideWidth)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setupView() {
        addSubviewWithAnchors(mainView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: Insets.zero)
        separator.delegate = self
        addSubviewWithAnchors(separator, top: topAnchor, leading: mainView.trailingAnchor, bottom: bottomAnchor, insets: Insets.zero)
            .width(8)
        addSubviewWithAnchors(sideView, top: topAnchor, leading: separator.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: Insets.zero)
        sideViewWidthConstraint.isActive = true
    }
    
    open func setSideWidth(_ width: CGFloat){
        sideViewWidthConstraint.constant = width
    }
    
    open func closeSideView(){
        setSideWidth(0)
    }
    
    open func openSideView(){
        setSideWidth(defaultSideWidth)
    }
    
    open func toggleSideView(){
        if sideViewWidthConstraint.constant <= minSideWidth{
            setSideWidth(defaultSideWidth)
        }
        else{
            setSideWidth(0)
        }
    }
    
}

extension SplitView: ViewSeparatorDelegate{
    
    public func dragged(by dx: CGFloat){
        sideViewWidthConstraint.constant = min(max(minSideWidth, sideViewWidthConstraint.constant - dx), maxSideWidth)
    }
    
}
