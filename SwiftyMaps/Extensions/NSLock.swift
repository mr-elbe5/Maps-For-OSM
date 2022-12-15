//
//  NSLock.swift
//  SwiftyMaps
//
//  Created by Michael Rönnau on 13.11.21.
//

import Foundation

extension NSLock {
    func withCriticalScope<T>(block:() -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
