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
    
    static func export() -> (Int, Int){
        var numCopied = 0
        var numErrors = 0
        for location in LocationPool.list{
            for media in location.media{
                FileController.copyImageToLibrary(name: media.data.fileName, fromDir: FileController.mediaDirURL){ result in
                    switch result{
                    case .success:
                        numCopied += 1
                    case .failure:
                        numErrors += 1
                    }
                }
            }
        }
        return (numCopied, numErrors)
    }
    
    static func createBackupFile(name: String) -> URL?{
        do {
            var paths = Array<URL>()
            let zipFileURL = FileController.temporaryURL.appendingPathComponent(name)
            paths.append(FileController.mediaDirURL)
            
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

    

