/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class SplitView: NSView{
    
    var mainView: NSView
    var separator = ViewSeparator()
    var sideView: NSView
    var sideViewWidthConstraint = NSLayoutConstraint()
    
    var minSideWidth: CGFloat = 200
    
    var defaultSideWidth: CGFloat{
        max(minSideWidth, bounds.width / 4)
    }
    
    var maxSideWidth: CGFloat{
        bounds.width / 2
    }
    
    init(mainView: NSView, sideView: NSView) {
        self.mainView = mainView
        self.sideView = sideView
        super.init(frame: .zero)
        self.sideViewWidthConstraint = sideView.widthAnchor.constraint(equalToConstant: minSideWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        addSubviewWithAnchors(mainView, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: Insets.zero)
        separator.delegate = self
        addSubviewWithAnchors(separator, top: topAnchor, leading: mainView.trailingAnchor, bottom: bottomAnchor, insets: Insets.zero)
            .width(8)
        addSubviewWithAnchors(sideView, top: topAnchor, leading: separator.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: Insets.zero)
        sideViewWidthConstraint.isActive = true
    }
    
    func setSideWidth(_ width: CGFloat){
        sideViewWidthConstraint.constant = width
    }
    
    func closeSideView(){
        setSideWidth(0)
    }
    
    func openSideView(){
        setSideWidth(defaultSideWidth)
    }
    
    func toggleSideView(){
        if sideViewWidthConstraint.constant <= minSideWidth{
            setSideWidth(defaultSideWidth)
        }
        else{
            setSideWidth(0)
        }
    }
    
}

extension SplitView: ViewSeparatorDelegate{
    
    func dragged(by dx: CGFloat){
        sideViewWidthConstraint.constant = min(max(minSideWidth, sideViewWidthConstraint.constant - dx), maxSideWidth)
    }
    
}
