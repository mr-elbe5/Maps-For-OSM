/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import Photos
import Zip

class Backup{
    
    static func createBackupFile(name: String) -> URL?{
        do {
            FileController.deleteTemporaryFiles()
            var paths = Array<URL>()
            let zipFileURL = FileController.backupDirURL.appendingPathComponent(name)
            paths.append(FileController.mediaDirURL)
            if let url = AppData.shared.saveAsFile(){
                paths.append(url)
            }
            if let url = Preferences.saveAsFile(){
                paths.append(url)
            }
            if let url = AppState.saveAsFile(){
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
            FileController.deleteTemporaryFiles()
            try FileManager.default.createDirectory(at: FileController.temporaryURL, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: FileController.temporaryURL, overwrite: true, password: nil, progress: { (progress) -> () in
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
        FileController.deleteAllFiles(dirURL: FileController.mediaDirURL)
        let fileNames = FileController.listAllFiles(dirPath: FileController.temporaryURL.appendingPathComponent("media").path)
        for name in fileNames{
            FileController.copyFile(fromURL: FileController.temporaryURL.appendingPathComponent("media").appendingPathComponent(name), toURL: FileController.mediaDirURL.appendingPathComponent(name), replace: true)
        }
        var url = FileController.temporaryURL.appendingPathComponent(AppState.storeKey + ".json")
        AppState.loadFromFile(url: url)
        url = FileController.temporaryURL.appendingPathComponent(Preferences.storeKey + ".json")
        Preferences.loadFromFile(url: url)
        Preferences.shared.save()
        url = FileController.temporaryURL.appendingPathComponent(AppData.storeKey + ".json")
        AppData.shared.loadFromFile(url: url)
        AppData.shared.save()
        url = FileController.temporaryURL.appendingPathComponent(TrackPool.storeKey + ".json")
        if FileController.fileExists(url: url){
            TrackPool.loadFromFile(url: url)
            TrackPool.addTracksToPlaces()
            AppData.shared.convertNotes()
        }
        FileController.deleteTemporaryFiles()
        return true
    }
    
}
