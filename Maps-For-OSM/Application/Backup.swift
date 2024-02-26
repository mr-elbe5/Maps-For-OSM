/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import CoreLocation
import Zip

class Backup{
    
    static func exportImages() -> (Int, Int){
        var numCopied = 0
        var numErrors = 0
        for location in LocationPool.list{
            for media in location.media{
                if let image = media.data as? ImageFile{
                    FileController.copyImageToLibrary(name: image.fileName, fromDir: FileController.mediaDirURL){ result in
                        switch result{
                        case .success:
                            numCopied += 1
                        case .failure:
                            numErrors += 1
                        }
                    }
                }
            }
        }
        return (numCopied, numErrors)
    }
    
    static func getMediaUrls() -> [URL]{
        var urls = [URL]()
        for location in LocationPool.list{
            for media in location.media{
                let url = FileController.mediaDirURL.appendingPathComponent(media.data.fileName)
                urls.append(url)
            }
        }
        return urls
    }
    
    static func createBackupFile(name: String) -> URL?{
        do {
            FileController.deleteTemporaryFiles()
            var paths = Array<URL>()
            let zipFileURL = FileController.temporaryURL.appendingPathComponent(name)
            paths.append(FileController.mediaDirURL)
            for track in TrackPool.list{
                if let trackFileURL = GPXCreator.createTemporaryFile(track: track){
                    paths.append(trackFileURL)
                }
            }
            if let url = LocationPool.saveAsFile(){
                paths.append(url)
            }
            if let url = TrackPool.saveAsFile(){
                paths.append(url)
            }
            if let url = Preferences.saveAsFile(){
                paths.append(url)
            }
            if let url = AppState.saveAsFile(){
                paths.append(url)
            }
            try Zip.zipFiles(paths: paths, zipFilePath: zipFileURL, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            return zipFileURL
        }
        catch let err {
            print(err)
            Log.error("could not create zip file")
        }
        return nil
    }
    
    static func unzipBackupFile(zipFileURL: URL) -> Bool{
        do {
            FileController.deleteTemporaryFiles()
            let destDirectory = FileController.temporaryURL
            try FileManager.default.createDirectory(at: destDirectory, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: destDirectory, overwrite: true, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            return true
        }
        catch {
            Log.error("could not read zip file")
        }
        return false
    }
    
    static func restoreBackup() -> Bool{
        FileController.deleteAllFiles(dirURL: FileController.mediaDirURL)
        let fileNames = FileController.listAllFiles(dirPath: FileController.temporaryURL.appendingPathComponent("media").path)
        for name in fileNames{
            FileController.copyFile(fromURL: FileController.temporaryURL.appendingPathComponent("media").appendingPathComponent(name), toURL: FileController.mediaDirURL.appendingPathComponent(name), replace: true)
        }
        FileController.deleteTemporaryFiles()
        return true
    }
    
}

    

