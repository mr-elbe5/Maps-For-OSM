/*
 E5Data
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

protocol LogDelegate{
    func newLog(log: String)
}

class Log{
    
    enum LogLevel: Int{
        case none
        case error
        case warn
        case info
        case debug
    }
    
    static var cache = Array<String>()
    
    static var useCache = false
    
    static var logLevel: LogLevel = .info
    
    static var delegate: LogDelegate? = nil
    
    private static func log(_ str: String){
        let logStr = "\(Date().longDateTimeString())\n \(str)"
        print(logStr)
        if useCache{
            cache.append(logStr)
        }
        delegate?.newLog(log: logStr)
    }

    static func debug(_ msg: String){
        if logLevel.rawValue >= LogLevel.debug.rawValue{
            log("debug: \(msg)")
        }
    }

    static func info(_ msg: String){
        if logLevel.rawValue >= LogLevel.info.rawValue{
            log("info: \(msg)")
        }
    }

    static func warn(_ msg: String){
        if logLevel.rawValue >= LogLevel.warn.rawValue{
            log("warn: \(msg)")
        }
    }

    static func error(_ msg: String){
        if logLevel.rawValue >= LogLevel.error.rawValue{
            log("error: \(msg)")
        }
    }

    static func error(_ msg: String, error: Error){
        if logLevel.rawValue >= LogLevel.error.rawValue{
            log("error: \(msg): \(error.localizedDescription)")
        }
    }

    static func error(error: Error){
        if logLevel.rawValue >= LogLevel.error.rawValue{
            log("error: \(error.localizedDescription)")
        }
    }

    static func error(msg: String, error: Error){
        if logLevel.rawValue >= LogLevel.error.rawValue{
            log("error: \(msg): \(error.localizedDescription)")
        }
    }
    
}
