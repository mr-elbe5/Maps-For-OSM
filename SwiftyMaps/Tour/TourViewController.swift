//
//  TourViewController.swift
//  SwiftyMaps
//
//  Created by Michael Rönnau on 20.09.21.
//

import Foundation
import UIKit

class TourViewController: PopupViewController{
    
    var stackView = UIStackView()
    
    override func loadView() {
        title = "tour".localize()
        super.loadView()
        scrollView.setupVertical()
        contentView.addSubview(stackView)
        stackView.fillView(view: scrollView, insets: UIEdgeInsets(top: Insets.defaultInset, left: .zero, bottom: Insets.defaultInset, right: .zero))
        stackView.setupVertical()
        setupKeyboard()
    }
    
}
