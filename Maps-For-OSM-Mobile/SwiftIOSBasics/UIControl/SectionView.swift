/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class SectionView: UIView{
    
    init(){
        super.init(frame: .zero)
        backgroundColor = .tertiarySystemBackground
        setRoundedBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ArrangedSectionView: SectionView{
    
    var stackView = UIStackView()
    
    override init(){
        super.init()
        stackView.axis = .vertical
        addSubviewFilling(stackView, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addArrangedSubview(_ subview: UIView){
        stackView.addArrangedSubview(subview)
    }
    
    func addSpacer(){
        stackView.addSpacer()
    }
    
    func removeAllArrangedSubviews(){
        stackView.removeAllArrangedSubviews()
    }
    
}

