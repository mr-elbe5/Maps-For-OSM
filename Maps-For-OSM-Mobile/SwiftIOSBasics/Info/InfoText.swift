/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class InfoText : UIView{
    
    let label = UILabel()
    
    init(text: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        label.text = text
        label.numberOfLines = 0
        label.textColor = .label
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: leftInset, bottom: defaultInset, right: 0))
    }
    
    init(key: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        label.text = key.localize(table: "Info")
        label.numberOfLines = 0
        label.textColor = .label
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: leftInset, bottom: defaultInset, right: 0))
    }
    
    init(_ text: String){
        super.init(frame: .zero)
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
        label.fillView(view: self, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

