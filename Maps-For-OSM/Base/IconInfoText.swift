/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class IconInfoText : UIView{
    
    let iconView = UIImageView()
    let iconText = UILabel()
    
    init(icon: String, text: String, iconColor : UIColor = .darkGray, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = iconColor
        iconText.text = text
        commonInit(leftInset: leftInset)
    }
    
    init(icon: String, key: String, iconColor : UIColor = .darkGray, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = iconColor
        iconText.text = key.localize(table: "Info")
        commonInit(leftInset: leftInset)
    }
    
    init(image: String, text: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(named: image)
        iconText.text = text
        commonInit(leftInset: leftInset)
    }
    
    init(image: String, key: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(named: image)
        iconText.text = key.localize(table: "Info")
        commonInit(leftInset: leftInset)
    }
    
    private func commonInit(leftInset: CGFloat){
        iconText.numberOfLines = 0
        iconText.textColor = .label
        addSubviewWithAnchors(iconView, top: topAnchor, leading: leadingAnchor, insets: UIEdgeInsets(top: defaultInset, left: leftInset, bottom: defaultInset, right: 0))
            .width(25)
        iconView.setAspectRatioConstraint()
        addSubviewWithAnchors(iconText, top: topAnchor, leading: iconView.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

