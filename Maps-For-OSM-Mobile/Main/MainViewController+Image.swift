/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import AVFoundation
import PhotosUI

extension MainViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func importImages() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.any(of: [.images, .videos])
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .ordered
        configuration.selectionLimit = 0
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results{
            var location: CLLocation? = nil
            var creationDate : Date? = nil
            if let ident = result.assetIdentifier{
                if let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil).firstObject{
                    location = fetchResult.location
                    creationDate = fetchResult.creationDate
                }
            }
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) {  uiimage, error in
                    if let uiimage = uiimage as? UIImage {
                        //Log.debug("got image \(uiimage.description) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
                        if let coordinate = location?.coordinate{
                            var newLocation = false
                            var location = AppData.shared.getLocation(coordinate: coordinate)
                            if location == nil{
                                location = AppData.shared.createLocation(coordinate: coordinate)
                                newLocation = true
                            }
                            let image = ImageItem()
                            image.creationDate = creationDate ?? Date.localDate
                            image.saveImage(uiImage: uiimage)
                            location!.addItem(item: image)
                            DispatchQueue.main.async {
                                if newLocation{
                                    self.locationsChanged()
                                }
                                else{
                                    self.locationChanged(location: location!)
                                }
                            }
                        }
                    }
                }
            }
            else{
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, err in
                    if let url = url {
                        //Log.debug("got video url: \(url) at location \(location?.coordinate ?? CLLocationCoordinate2D())")
                        if let coordinate = location?.coordinate{
                            var newLocation = false
                            var location = AppData.shared.getLocation(coordinate: coordinate)
                            if location == nil{
                                location = AppData.shared.createLocation(coordinate: coordinate)
                                newLocation = true
                            }
                            let video = VideoItem()
                            video.creationDate = creationDate ?? Date.localDate
                            video.setFileNameFromURL(url)
                            if let data = FileManager.default.readFile(url: url){
                                video.saveFile(data: data)
                                location!.addItem(item: video)
                                DispatchQueue.main.async {
                                    if newLocation{
                                        self.locationsChanged()
                                    }
                                    else{
                                        self.locationChanged(location: location!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        picker.dismiss(animated: false)
    }
    
    func openAddImage(at coordinate: CLLocationCoordinate2D) {
        let pickerController = ImagePickerController()
        pickerController.coordinate = coordinate
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickerController = picker as? ImagePickerController, let imageURL = info[.imageURL] as? URL, let data = FileManager.default.readFile(url: imageURL){
            var coordinate: CLLocationCoordinate2D?
            if let coord = pickerController.coordinate{
                coordinate = coord
            }
            else{
                coordinate = LocationService.shared.location?.coordinate
            }
            let image = ImageItem()
            var imageData = data
            let metaData = ImageMetaData()
            metaData.readData(data: data)
            if !metaData.hasGPSData, let coordinate = coordinate{
                if let dataWithCoordinates = data.setImageProperties(altitude: nil, latitude: coordinate.latitude, longitude: coordinate.longitude, utType: image.fileURL.utType!){
                    imageData = dataWithCoordinates
                }
            }
            if let coordinate = coordinate, FileManager.default.saveFile(data: imageData, url: image.fileURL){
                var newLocation = false
                var location = AppData.shared.getLocation(coordinate: coordinate)
                if location == nil{
                    location = AppData.shared.createLocation(coordinate: coordinate)
                    newLocation = true
                }
                location!.addItem(item: image)
                AppData.shared.save()
                DispatchQueue.main.async {
                    if newLocation{
                        self.locationsChanged()
                    }
                    else{
                        self.locationChanged(location: location!)
                    }
                    self.showLocationOnMap(coordinate: location!.coordinate)
                }
                picker.dismiss(animated: false)
                return
            }
            
        }
        picker.dismiss(animated: false)
        showError("imageImportError".localize())
    }
    
}


