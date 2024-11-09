/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import Foundation

extension Array{
    
    mutating func remove<T : Equatable>(obj : T){
        for i in 0..<count{
            if obj == self[i] as? T{
                remove(at: i)
                return
            }
        }
    }
    
    func getTypedArray<T>(type: T.Type) -> Array<T>{
        var arr = Array<T>()
        for data in self{
            if let obj = data as? T {
                arr.append(obj)
            }
        }
        return arr
    }
    
    func containsEqual(_ obj: IdObject) -> Bool{
        self.contains(where: {
            ($0 as? IdObject)?.equals(obj) ?? false
        })
    }
    
    func containsEqual(_ obj: UUIDObject) -> Bool{
        self.contains(where: {
            ($0 as? UUIDObject)?.equals(obj) ?? false
        })
    }
    
    var allSelected: Bool{
        get{
            allSatisfy({
                ($0 as? Selectable)?.selected ?? false
            })
        }
    }
    
    var allUnselected: Bool{
        get{
            allSatisfy({
                !(($0 as? Selectable)?.selected ?? false)
            })
        }
    }
    
    mutating func selectAll(){
        for item in self{
            (item as? Selectable)?.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            (item as? Selectable)?.selected = false
        }
    }
    
}

