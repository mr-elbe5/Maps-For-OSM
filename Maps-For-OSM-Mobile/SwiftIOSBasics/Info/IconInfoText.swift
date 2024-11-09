/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class IconInfoText : UIView{
    
    let iconContainer = UIView()
    let iconView = UIImageView()
    let iconText = UILabel()
    
    init(icon: String, text: String, iconColor : UIColor = .label, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = iconColor
        iconText.text = text
        setup(leftInset: leftInset)
    }
    
    init(icon: String, key: String, iconColor : UIColor = .label, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = iconColor
        iconText.text = key.localize(table: "Info")
        setup(leftInset: leftInset)
    }
    
    init(image: String, text: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(named: image)
        iconText.text = text
        setup(leftInset: leftInset)
    }
    
    init(image: String, key: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        iconView.image = UIImage(named: image)
        iconText.text = key.localize(table: "Info")
        setup(leftInset: leftInset)
    }
    
    private func setup(leftInset: CGFloat){
        iconText.numberOfLines = 0
        iconText.textColor = .label
        addSubviewWithAnchors(iconContainer, top: topAnchor, leading: leadingAnchor, insets: UIEdgeInsets(top: defaultInset, left: leftInset, bottom: defaultInset, right: 0))
            .width(25)
        iconContainer.addSubviewWithAnchors(iconView, top: iconContainer.topAnchor, leading: iconContainer.leadingAnchor, bottom: iconContainer.bottomAnchor, insets: .zero)
        addSubviewWithAnchors(iconText, top: topAnchor, leading: iconContainer.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

