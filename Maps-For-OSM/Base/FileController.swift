/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit
import Photos
import Compression

class FileController {
    
    private static let tempDir = NSTemporaryDirectory()
    static var privateURL : URL = FileManager.default.urls(for: .applicationSupportDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
    static var documentURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var imageLibraryPath: String = NSSearchPathForDirectoriesInDomains(.picturesDirectory,.userDomainMask,true).first!
    static var imageLibraryURL : URL = FileManager.default.urls(for: .picturesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var mediaDirURL : URL = privateURL.appendingPathComponent("media")
    static var tilesDirURL : URL = privateURL.appendingPathComponent("tiles")
    static var exportGpxDirURL = documentURL.appendingPathComponent("gpx")
    static var exportMediaDirURL = documentURL.appendingPathComponent("media")
    static var backupDirURL = documentURL.appendingPathComponent("backup")
    
    static var temporaryPath : String {
        tempDir
    }
    
    static var temporaryURL : URL{
        URL(fileURLWithPath: temporaryPath, isDirectory: true)
    }
    
    static var privatePath : String{
        privateURL.path
    }
    
    static func initialize() {
        try! FileManager.default.createDirectory(at: FileController.privateURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileController.tilesDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileController.mediaDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileController.exportGpxDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileController.backupDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileController.exportMediaDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func getPath(dirPath: String, fileName: String ) -> String
    {
        dirPath+"/"+fileName
    }
    
    static func getURL(dirURL: URL, fileName: String ) -> URL
    {
        return dirURL.appendingPathComponent(fileName)
    }
    
    static func fileExists(dirPath: String, fileName: String) -> Bool{
        let path = getPath(dirPath: dirPath,fileName: fileName)
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func fileExists(url: URL) -> Bool{
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func isDirectory(url: URL) -> Bool{
        var isDir:ObjCBool = true
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }
    
    static func readFile(url: URL) -> Data?{
        if let fileData = FileManager.default.contents(atPath: url.path){
            return fileData
        }
        return nil
    }
    
    static func readTextFile(url: URL) -> String?{
        do{
            let string = try String(contentsOf: url, encoding: .utf8)
            return string
        }
        catch{
            return nil
        }
    }
    
    static func assertDirectoryFor(url: URL) -> Bool{
        let dirUrl = url.deletingLastPathComponent()
        var isDir:ObjCBool = true
        if !FileManager.default.fileExists(atPath: dirUrl.path, isDirectory: &isDir) {
            do{
                try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true)
            }
            catch let err{
                Log.error("FileController could not create directory", error: err)
                return false
            }
        }
        return true
    }
    
    @discardableResult
    static func saveFile(data: Data, url: URL) -> Bool{
        do{
            try data.write(to: url, options: .atomic)
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    @discardableResult
    static func saveFile(text: String, url: URL) -> Bool{
        do{
            try text.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    @discardableResult
    static func copyFile(name: String,fromDir: URL, toDir: URL, replace: Bool = false) -> Bool{
        do{
            if replace && fileExists(url: getURL(dirURL: toDir, fileName: name)){
                _ = deleteFile(url: getURL(dirURL: toDir, fileName: name))
            }
            try FileManager.default.copyItem(at: getURL(dirURL: fromDir,fileName: name), to: getURL(dirURL: toDir, fileName: name))
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    @discardableResult
    static func copyFile(fromURL: URL, toURL: URL, replace: Bool = false) -> Bool{
        //Log.debug("FileController copying from \(fromURL.path) to \(toURL.path)")
        do{
            if replace && fileExists(url: toURL){
                _ = deleteFile(url: toURL)
            }
            try FileManager.default.copyItem(at: fromURL, to: toURL)
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    static func askPhotoLibraryAuthorization(callback: @escaping (Result<Void, Error>) -> Void){
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized:
            callback(.success(()))
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(){ granted in
                if granted == .authorized{
                    callback(.success(()))
                }
                else{
                    callback(.failure(AuthorizationError()))
                }
            }
            break
        default:
            callback(.failure(AuthorizationError()))
            break
        }
    }
    
    static func copyImageToLibrary(name: String, fromDir: URL, callback: @escaping (Result<Void, FileError>) -> Void){
        askPhotoLibraryAuthorization(){ result in
            switch result{
            case .success(()):
                let url = getURL(dirURL: fromDir, fileName: name)
                if let data = readFile(url: url){
                    if let image = UIImage(data: data){
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        callback(.success(()))
                        return
                    }
                    else{
                        callback(.failure(.save))
                        return
                    }
                }
                else{
                    callback(.failure(.read))
                }
                break
            case .failure:
                callback(.failure(.unauthorized))
            }
        }
    }
    
    static func copyVideoToLibrary(name: String, fromDir: URL, callback: @escaping (Result<Void, FileError>) -> Void){
        askPhotoLibraryAuthorization(){ result in
            switch result{
            case .success(()):
                let url = getURL(dirURL: fromDir, fileName: name)
                if let data = readFile(url: url){
                    PHPhotoLibrary.shared().performChanges {
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: data, options: nil)
                    } completionHandler: { success, error in
                        if let error {
                            Log.error("Error saving video: \(error.localizedDescription)")
                            callback(.failure(.save))
                            return
                        }
                        callback(.success(()))
                        return
                    }
                }
                else{
                    callback(.failure(.read))
                }
                break
            case .failure:
                callback(.failure(.unauthorized))
            }
        }
    }
    
    static func copyImageFromLibrary(name: String, fromDir: URL, callback: @escaping ( Result<Void, FileError>) -> Void){
        askPhotoLibraryAuthorization(){ result in
            switch result{
            case .success(()):
                let url = getURL(dirURL: fromDir, fileName: name)
                if let data = readFile(url: url){
                    if let image = UIImage(data: data){
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        callback(.success(()))
                        return
                    }
                    else{
                        callback(.failure(.save))
                        return
                    }
                }
                else{
                    callback(.failure(.read))
                }
                break
            case .failure:
                callback(.failure(.unauthorized))
            }
        }
    }
    
    @discardableResult
    static func renameFile(dirURL: URL, fromName: String, toName: String) -> Bool{
        do{
            try FileManager.default.moveItem(at: getURL(dirURL: dirURL, fileName: fromName),to: getURL(dirURL: dirURL, fileName: toName))
            return true
        }
        catch {
            return false
        }
    }
    
    @discardableResult
    static func deleteFile(dirURL: URL, fileName: String) -> Bool{
        do{
            try FileManager.default.removeItem(at: getURL(dirURL: dirURL, fileName: fileName))
            return true
        }
        catch {
            return false
        }
    }
    
    @discardableResult
    static func deleteFile(url: URL) -> Bool{
        do{
            try FileManager.default.removeItem(at: url)
            return true
        }
        catch {
            return false
        }
    }
    
    static func listAllFiles(dirPath: String) -> Array<String>{
        return try! FileManager.default.contentsOfDirectory(atPath: dirPath)
    }
    
    static func listAllURLs(dirURL: URL) -> Array<URL>{
        let names = listAllFiles(dirPath: dirURL.path)
        var urls = Array<URL>()
        for name in names{
            urls.append(getURL(dirURL: dirURL, fileName: name))
        }
        return urls
    }
    
    static func deleteAllFiles(dirURL: URL){
        let names = listAllFiles(dirPath: dirURL.path)
        var count = 0
        for name in names{
            if deleteFile(dirURL: dirURL, fileName: name){
                count += 1
            }
        }
        if count > 0{
            Log.info("\(count) files deleted")
        }
    }
    
    static func deleteTemporaryFiles(){
        if !FileManager.default.fileExists(atPath: temporaryPath){
            return
        }
        deleteAllFiles(dirURL: temporaryURL)
    }
    
    static func logFileInfo(){
        var names = listAllFiles(dirPath: temporaryPath)
        for name in names{
            print(name)
        }
        names = listAllFiles(dirPath: FileController.mediaDirURL.path)
        for name in names{
            print(name)
        }
    }
    
}
