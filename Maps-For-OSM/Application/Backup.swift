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
            try FileManager.default.createDirectory(at: FileController.temporaryURL, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: FileController.temporaryURL, overwrite: true, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            return true
        }
        catch (let err){
            print(err.localizedDescription)
            Log.error("could not read zip file")
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
        url = FileController.temporaryURL.appendingPathComponent(LocationPool.storeKey + ".json")
        LocationPool.loadFromFile(url: url)
        LocationPool.save()
        url = FileController.temporaryURL.appendingPathComponent(TrackPool.storeKey + ".json")
        TrackPool.loadFromFile(url: url)
        TrackPool.save()
        FileController.deleteTemporaryFiles()
        return true
    }
    
    static func exportToPhotoLibrary(resultHandler: @escaping(Int) -> Void){
        DispatchQueue.global(qos: .userInitiated).async {
            var numCopied = 0
            for location in LocationPool.list{
                for media in location.media{
                    switch (media.type){
                    case .image:
                        if let data = media.data.getFile(){
                            if media.type == .image{
                                PhotoLibrary.savePhoto(photoData: data, fileType: .jpg, location: CLLocation(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: location.timestamp), resultHandler: { localIdentifier in
                                    media.data.localIdentifier = localIdentifier
                                    numCopied += 1
                                })
                            }
                        }
                    case .video:
                        PhotoLibrary.saveVideo(outputFileURL: media.data.fileURL, location: CLLocation(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: location.timestamp), resultHandler: { localIdentifier in
                            media.data.localIdentifier = localIdentifier
                            numCopied += 1
                        })
                    default:
                        break
                    }
                }
                LocationPool.save()
            }
            DispatchQueue.main.async {
                resultHandler(numCopied)
            }
        }
    }
    
    
}
