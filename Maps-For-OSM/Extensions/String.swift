/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

extension String {
    
    func localize() -> String{
        return NSLocalizedString(self,comment: "")
    }
    
    func localize(table: String) -> String{
        return NSLocalizedString(self,tableName: table, comment: "")
    }
    
    func localize(i: Int) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(i))
    }
    
    func localize(i1: Int, i2: Int) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(i1), String(i2))
    }
    
    func localize(s: String) -> String{
        return String(format: NSLocalizedString(self,comment: ""), s)
    }
    
    func localize(param: String) -> String{
        return String(format: self.localize(), param)
    }
    
    func localize(param1: String, param2: String) -> String{
        return String(format: self.localize(), param1, param2)
    }
    
    func trim() -> String{
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removeTimeStringMilliseconds() -> String{
        if self.hasSuffix("Z"), let idx = self.lastIndex(of: "."){
            return self[self.startIndex ..< idx] + "Z"
        }
        return self
    }
    
    func ISO8601Date() -> Date?{
        ISO8601DateFormatter().date(from: self.removeTimeStringMilliseconds())
    }

}
