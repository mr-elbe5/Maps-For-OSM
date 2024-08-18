/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

public protocol RadioGroupDelegate{
    func valueDidChangeTo(idx: Int, value: String)
}

open class RadioGroup: NSView{
    
    public var selectedIndex : Int = -1
    public var selectedValue : String{
        if selectedIndex != -1{
            return radioViews[selectedIndex].title
        }
        return ""
    }
    
    public var radioViews = Array<NSButton>()
    public var stackView = NSStackView()
    
    public var delegate: RadioGroupDelegate? = nil
    
    public init(){
        super.init(frame: .zero)
        setRoundedBorders()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup(values: Array<String>, includingNobody: Bool = false){
        stackView.orientation = .vertical
        stackView.alignment = .leading
        addSubview(stackView)
        stackView.fillSuperview()
        if includingNobody{
            let radioView = NSButton(radioButtonWithTitle: "nobody", target: self, action: #selector(radioIsSelected))
            radioViews.append(radioView)
            stackView.addArrangedSubview(radioView)
        }
        for i in 0..<values.count{
            let radioView = NSButton(radioButtonWithTitle: values[i], target: self, action: #selector(radioIsSelected))
            radioViews.append(radioView)
            stackView.addArrangedSubview(radioView)
        }
    }
    
    public func select(index: Int){
        selectedIndex = index
        for i in 0..<radioViews.count{
            let radioView = radioViews[i]
            radioView.state = i == index ? .on : .off
        }
    }
    
    public func select(title: String){
        for i in 0..<radioViews.count{
            let radioView = radioViews[i]
            if radioView.title == title{
                radioView.state = .on
                selectedIndex = i
            }
            else{
                radioView.state =  .off
            }
        }
    }
    
    @objc public func radioIsSelected(sender: AnyObject) {
        if let selectedRadio = sender as? NSButton{
            for i in 0..<radioViews.count{
                let radioView = radioViews[i]
                if radioView == selectedRadio{
                    radioView.state = .on
                    selectedIndex = i
                }
                else{
                    radioView.state = .off
                }
            }
            delegate?.valueDidChangeTo(idx: selectedIndex, value: selectedValue)
        }
    }
    
}


