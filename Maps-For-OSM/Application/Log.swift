/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class Log{
    
    private static var logString = "";
    
    private static func log(_ str: String){
        print(str)
        logString += str + "\n"
    }

    static func debug(_ msg: String){
        log("debug: \(msg)")
    }

    static func info(_ msg: String){
        log("info: \(msg)")
    }

    static func warn(_ msg: String){
        log("warn: \(msg)")
    }

    static func error(_ msg: String){
        log("error: \(msg)")
    }

    static func error(_ msg: String, error: Error){
        log("error: \(msg): \(error.localizedDescription)")
    }

    static func error(error: Error){
        log("error: \(error.localizedDescription)")
    }

    static func error(msg: String, error: Error){
        log("error: \(msg): \(error.localizedDescription)")
    }

    static func save(){
        if !logString.isEmpty{
            FileController.saveFile(text: logString, url: FileController.logFileURL)
            logString = ""
        }
    }
    
}
