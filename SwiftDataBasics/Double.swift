/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import Foundation

extension Double{
    
    func withMaxDigits(num: Int) -> Double{
        let factor = pow(10,Double(num))
        return (self*factor).rounded()/factor
    }
    
}
