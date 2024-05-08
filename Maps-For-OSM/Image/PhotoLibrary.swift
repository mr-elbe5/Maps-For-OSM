/*
 E5Cam
 Simple Camera
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Photos

class PhotoLibrary{
    
    static var defaultFileType: AVFileType = .jpg
    
    static var albumName = ""
    
    static  func initializeAlbum(albumName: String){
        if albumName.isEmpty{
            return
        }
        PhotoLibrary.albumName = albumName
        if let _ = getAlbum(){
            return
        }
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoLibrary.albumName)
                }) { success, error in
                    if let error = error {
                        Log.error("\(error.localizedDescription)")
                        PhotoLibrary.albumName = ""
                    }
                }
            }
            else{
                Log.error("No authorization for creating an album")
                PhotoLibrary.albumName = ""
            }
        }
    }
    
    static func getAlbum() -> PHAssetCollection?{
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoLibrary.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let album: PHAssetCollection = collection.firstObject {
            return album
        }
        return nil
    }
    
    static func savePhoto(photoData: Data, fileType: AVFileType?, location: CLLocation?, resultHandler: @escaping (String) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                var localIdentifier: String = ""
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = fileType?.rawValue ?? defaultFileType.rawValue
                    let resourceType = PHAssetResourceType.photo
                    creationRequest.addResource(with: resourceType, data: photoData, options: options)
                    creationRequest.location = location
                    localIdentifier = creationRequest.placeholderForCreatedAsset!.localIdentifier
                }, completionHandler: { _, error in
                    if let error = error {
                        Log.error("Error occurred while saving photo to photo library: \(error)")
                    }
                    if !albumName.isEmpty{
                        addToAlbum(localIdentifier: localIdentifier)
                    }
                    DispatchQueue.main.async{
                        resultHandler(localIdentifier)
                    }
                })
            } else {
                resultHandler("")
            }
        }
    }
    
    static func saveVideo(outputFileURL: URL, location: CLLocation?, resultHandler: @escaping (String) -> Void){
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                var localIdentifier: String = ""
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    creationRequest.location = location
                    localIdentifier = creationRequest.placeholderForCreatedAsset!.localIdentifier
                }, completionHandler: { success, error in
                    if let error = error {
                        Log.error("Error. occurred while saving video to photo library: \(error)")
                    }
                    if !albumName.isEmpty{
                        addToAlbum(localIdentifier: localIdentifier)
                    }
                    resultHandler(localIdentifier)
                })
            } else {
                resultHandler("")
            }
        }
    }
    
    static func addToAlbum(localIdentifier: String){
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                if let album = getAlbum(){
                    PHPhotoLibrary.shared().performChanges({
                        let changeRequest = PHAssetCollectionChangeRequest(for: album)
                        changeRequest?.addAssets(PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil))
                    })
                }
            }
        }
    }
    
    static func fetchAsset(localIdentifier: String) -> PHAsset?{
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if assets.count == 1{
            return assets[0]
        }
        return nil
    }
    
    
}
