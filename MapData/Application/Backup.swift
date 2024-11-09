/*
 E5MapData
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import Photos
import Zip

class Backup{
    
    static func createBackupFile(at url: URL) -> Bool{
        do {
            let count = FileManager.default.deleteTemporaryFiles()
            if count > 0{
                Log.info("\(count) temporary files deleted before backup")
            }
            var paths = Array<URL>()
            paths.append(FileManager.mediaDirURL)
            if let url = AppData.shared.saveAsFile(){
                paths.append(url)
            }
            else{
                Log.error("could not create zip file: could not save json")
                return false
            }
            try Zip.zipFiles(paths: paths, zipFilePath: url, password: nil, progress: { (progress) -> () in
                //Log.debug(progress)
            })
            return true
        }
        catch let err {
            Log.error("could not create zip file: \(err.localizedDescription)")
        }
        return false
    }
    
    static func unzipBackupFile(zipFileURL: URL) -> Bool{
        do {
            let count = FileManager.default.deleteTemporaryFiles()
            if count > 0{
                Log.info("\(count) temporary files deleted before restore")
            }
            try FileManager.default.createDirectory(at: FileManager.tempURL, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: FileManager.tempURL, overwrite: true, password: nil, progress: { (progress) -> () in
                //Log.debug(progress)
            })
            return true
        }
        catch (let err){
            Log.error("could not read zip file: \(err.localizedDescription)")
        }
        return false
    }
    
    static func restoreBackupFile() -> Bool{
        var count = FileManager.default.deleteAllFiles(dirURL: FileManager.mediaDirURL)
        if count > 0{
            Log.info("\(count) media files deleted before restore")
        }
        let fileNames = FileManager.default.listAllFiles(dirPath: FileManager.tempURL.appendingPathComponent("media").path)
        for name in fileNames{
            FileManager.default.copyFile(fromURL: FileManager.tempURL.appendingPathComponent("media").appendingPathComponent(name), toURL: FileManager.mediaDirURL.appendingPathComponent(name), replace: true)
        }
        let url = FileManager.tempURL.appendingPathComponent(AppData.storeKey + ".json")
        AppData.shared.loadFromFile(url: url)
        AppData.shared.save()
        count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.info("\(count) temporary files deleted after restore")
        }
        return true
    }
    
}
