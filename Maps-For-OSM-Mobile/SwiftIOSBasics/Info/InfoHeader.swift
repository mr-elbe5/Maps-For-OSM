/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class InfoHeader : UIView{
    
    let label = UILabel()
    
    init(_ text: String, paddingTop: CGFloat = Insets.defaultInset){
        super.init(frame: .zero)
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        addSubview(label)
        label.setAnchors(leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
            .top(topAnchor, inset: paddingTop)
    }
    
    init(text: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textColor = .label
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: leftInset, bottom: defaultInset, right: 0))
    }
    
    init(key: String, leftInset: CGFloat = 0){
        super.init(frame: .zero)
        label.text = key.localize(table: "Info")
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textColor = .label
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: leftInset, bottom: defaultInset, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

