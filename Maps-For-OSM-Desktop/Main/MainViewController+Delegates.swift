/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVFoundation
import CoreLocation

extension MainViewController: MapViewDelegate, LocationGroupDelegate{
    
    func locationsChanged() {
        mapView.scrollView.updateLocationLayer()
    }
    
    func addImage(at coordinate: CLLocationCoordinate2D) {
        if let location = AppData.shared.getLocation(coordinate: coordinate){
            addImage(to: location)
        }
        else{
            let location = Location(coordinate: coordinate)
            addImage(to: location)
            if location.hasItems{
                AppData.shared.locations.append(location)
            }
        }
    }
    
    func addVideo(at coordinate: CLLocationCoordinate2D) {
        if let location = AppData.shared.getLocation(coordinate: coordinate){
            addVideo(to: location)
        }
        else{
            let location = Location(coordinate: coordinate)
            addVideo(to: location)
            if location.hasItems{
                AppData.shared.locations.append(location)
            }
        }
    }
    
    func addAudio(at coordinate: CLLocationCoordinate2D) {
        if let location = AppData.shared.getLocation(coordinate: coordinate){
            addAudio(to: location)
        }
        else{
            let location = Location(coordinate: coordinate)
            addAudio(to: location)
            if location.hasItems{
                AppData.shared.locations.append(location)
            }
        }
    }
    
    func addNote(at coordinate: CLLocationCoordinate2D) {
        if let location = AppData.shared.getLocation(coordinate: coordinate){
            addNote(to: location)
        }
        else{
            let location = Location(coordinate: coordinate)
            addNote(to: location)
            if location.hasItems{
                AppData.shared.locations.append(location)
            }
        }
    }
    
    func addImage(to location: Location) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.image]
        panel.directoryURL = FileManager.imagesURL
        if panel.runModal() == .OK, let url = panel.urls.first{
            let image = ImageItem()
            image.setFileNameFromURL(url)
            if FileManager.default.copyFile(fromURL: url, toURL: image.fileURL){
                location.items.append(image)
                image.location = location
                AppData.shared.save()
            }
        }
    }
    
    func addVideo(to location: Location) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.movie]
        panel.directoryURL = FileManager.movieLibraryURL
        if panel.runModal() == .OK, let url = panel.urls.first{
            let video = VideoItem()
            video.setFileNameFromURL(url)
            if FileManager.default.copyFile(fromURL: url, toURL: video.fileURL){
                location.items.append(video)
                video.location = location
                AppData.shared.save()
            }
        }
    }
    
    func addAudio(to location: Location) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.audio]
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        if panel.runModal() == .OK, let url = panel.urls.first{
            let audio = AudioItem()
            audio.setFileNameFromURL(url)
            if FileManager.default.copyFile(fromURL: url, toURL: audio.fileURL){
                location.items.append(audio)
                audio.location = location
                AppData.shared.save()
            }
        }
    }
    
    func addNote(to location: Location) {
        let note = NoteItem()
        note.location = location
        let controller = EditNoteViewController(note: note)
        if ModalWindow.run(title: "addNote".localize(), viewController: controller, outerWindow: MainWindowController.instance.window!, minSize: CGSize(width: 300, height: 200)) == .OK{
            location.addItem(item: controller.note)
            AppData.shared.save()
        }
    }
    
    func importTrack() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "gpx")!]
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        if panel.runModal() == .OK, let url = panel.urls.first{
            if url.pathExtension == "gpx"{
                importGPXFile(url: url)
            }
        }
    }
    
    private func importGPXFile(url: URL){
        if let gpxData = GPXParser.parseFile(url: url), !gpxData.isEmpty{
            let track = TrackItem()
            track.name = gpxData.name
            for segment in gpxData.segments{
                for point in segment.points{
                    track.trackpoints.append(Trackpoint(location: point.location))
                }
            }
            track.updateFromTrackpoints()
            track.simplifyTrack()
            if track.name.isEmpty{
                let ext = url.pathExtension
                var name = url.lastPathComponent
                name = String(name[name.startIndex...name.index(name.endIndex, offsetBy: -ext.count)])
                Log.debug(name)
                track.name = name
            }
            var location = AppData.shared.getLocation(coordinate: track.startCoordinate!)
            if location == nil{
                location = AppData.shared.createLocation(coordinate: track.startCoordinate!)
            }
            location!.addItem(item: track)
            AppData.shared.save()
            DispatchQueue.main.async {
                self.mapView.updateLocations()
                self.showTrackOnMap(track)
            }
        }
    }
    
    func deleteLocation(_ location: Location) {
        AppData.shared.deleteLocation(location)
    }
    
    func showLocationDetails(_ location: Location) {
        let detailView = LocationDetailView(location: location)
        detailView.setupView()
        openMapDetailView(detailView)
    }
    
    func showLocationGroupDetails(_ group: LocationGroup) {
        let detailView = LocationGroupDetailView(group: group)
        detailView.setupView()
        detailView.delegate = self
        openMapDetailView(detailView)
    }
    
    func openMapDetailView(_ view: MapDetailView){
        mapSplitView.openSideView()
        if let centerCoordinate = view.centerCoordinate{
            mapView.scrollView.scrollToScreenCenter(coordinate: centerCoordinate)
        }
        mapSplitView.sideView.removeAllSubviews()
        mapSplitView.sideView.addSubviewFilling(view)
        
    }
    
    func showImage(_ image: ImageItem) {
        setView(.presenter)
        mediaPresenterView.setMediaItem(item: image)
    }
    
    func showVideo(_ video: VideoItem) {
        setView(.presenter)
        mediaPresenterView.setMediaItem(item: video)
    }
    
    func showTrackOnMap(_ track: TrackItem) {
        setView(.map)
        mapView.scrollView.showTrack(track)
        if !track.trackpoints.isEmpty, let boundingRect = track.trackpoints.boundingMapRect{
            mapView.showMapRectOnMap(worldRect: boundingRect)
            mapView.scrollView.trackLayerView.showTrack(track)
        }
    }
    
    func showImageFullSize(_ image: ImageItem) {
        showImage(image)
    }
    
    func showLocationOnMap(_ location: Location) {
        setView(.map)
        showLocationDetails(location)
    }
    
    func exportImage(_ image: ImageItem) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        if panel.runModal() == .OK, let url = panel.urls.first{
            DispatchQueue.global(qos: .userInitiated).async{
                do{
                    let targetUrl = url.appendingPathComponent(image.fileName)
                    try FileManager.default.copyItem(at: image.fileURL, to: targetUrl)
                }
                catch{
                    DispatchQueue.main.async {
                        NSAlert.showError(message: "saveError".localize())
                    }
                }
            }
        }
    }
    
    func exportImages(_ images: Array<ImageItem>) {
        if !images.isEmpty{
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            if panel.runModal() == .OK, let url = panel.urls.first{
                DispatchQueue.global(qos: .userInitiated).async{
                    do{
                        for image in images{
                            let targetUrl = url.appendingPathComponent(image.fileName)
                            try FileManager.default.copyItem(at: image.fileURL, to: targetUrl)
                        }
                    }
                    catch{
                        DispatchQueue.main.async {
                            NSAlert.showError(message: "saveError".localize())
                        }
                    }
                }
            }
        }
    }
    
    func deleteImage(_ image: ImageItem) {
        image.prepareDelete()
        image.location.items.remove(image)
        imageGridView.updateData()
        if mediaPresenterView.items.contains(image){
            mediaPresenterView.items.remove(image)
            mediaPresenterView.updateMedia()
        }
    }
    
    func showImages(_ images: Array<ImageItem>) {
        setView(.presenter)
        mediaPresenterView.setMedia(images)
    }
    
    func trackDeleted(_ track: TrackItem){
        if TrackItem.visibleTrack == track{
            mapView.scrollView.showTrack(nil)
        }
    }
    
}





