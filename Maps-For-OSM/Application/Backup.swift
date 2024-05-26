/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import Photos
import Zip
import E5Data

class Backup{
    
    static func createBackupFile(name: String) -> URL?{
        do {
            let count = FileManager.default.deleteTemporaryFiles()
            if count > 0{
                Log.info("\(count) temporary files deleted before backup")
            }
            var paths = Array<URL>()
            let zipFileURL = FileManager.backupDirURL.appendingPathComponent(name)
            paths.append(FileManager.mediaDirURL)
            if let url = AppData.shared.saveAsFile(){
                paths.append(url)
            }
            try Zip.zipFiles(paths: paths, zipFilePath: zipFileURL, password: nil, progress: { (progress) -> () in
                //Log.debug(progress)
            })
            return zipFileURL
        }
        catch let err {
            Log.error("could not create zip file: \(err.localizedDescription)")
        }
        return nil
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
        var url = FileManager.tempURL.appendingPathComponent(AppData.storeKey + ".json")
        AppData.shared.loadFromFile(url: url)
        AppData.shared.saveLocally()
        //deprecated
        url = FileManager.tempURL.appendingPathComponent(TrackPool.storeKey + ".json")
        if FileManager.default.fileExists(url: url){
            TrackPool.loadFromFile(url: url)
            TrackPool.addTracksToPlaces()
            AppData.shared.convertNotes()
        }
        count = FileManager.default.deleteTemporaryFiles()
        if count > 0{
            Log.info("\(count) temporary files deleted after restore")
        }
        return true
    }
    
}
