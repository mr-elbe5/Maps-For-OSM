/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TilePreloadViewController: NavScrollViewController{
    
    static var maxDownloadTiles = 5000
    
    var mapRegion: TileRegion? = nil
    
    var downloadQueue : OperationQueue?
    var uploadQueue : OperationQueue?
    
    var allTiles = 0
    var existingTiles = 0
    var errors = 0
    
    var tiles = [MapTile]()
    
    var minZoomControl = UISegmentedControl()
    var maxZoomControl = UISegmentedControl()
    
    var minZoom : Int = 16
    var maxZoom : Int = 16
    
    var allTilesValueLabel = UILabel()
    var existingTilesValueLabel = UILabel()
    var tilesToLoadValueLabel = UILabel()
    
    var startButton = UIButton()
    var cancelButton = UIButton()
    
    var progressView = UIProgressView()
    
    var errorsValueLabel = UILabel()
    
    // watch upload
    
    var uploadedTiles = 0
    var uploadErrors = 0
    
    var watchTiles = [MapTile]()
    
    var watchStatusLabel = UILabel(text: "disconnected".localize())
    var startWatchUploadButton = UIButton()
    var cancelWatchUploadButton = UIButton()
    
    var watchProgressView = UIProgressView()
    
    var uploadErrorsValueLabel = UILabel()
    
    override func loadView() {
        title = "mapPreload".localize()
        super.loadView()
        if existingTiles == allTiles{
            startButton.isEnabled = false
            cancelButton.isEnabled = false
        }
        else{
            startButton.isEnabled = true
            cancelButton.isEnabled = false
        }
        if !WatchConnector.shared.isWatchConnectionActivated{
            WatchConnector.shared.start()
            DispatchQueue.main.async {
                self.updateConnectionStatus()
            }
        }
    }
    
    override func loadScrollableSubviews() {
        let note = UILabel()
        note.numberOfLines = 0
        note.lineBreakMode = .byWordWrapping
        note.text = "mapPreloadNote".localize()
        contentView.addSubviewWithAnchors(note, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let sourceLabel = UILabel()
        sourceLabel.numberOfLines = 0
        sourceLabel.text = "\("currentTileSource:".localize())\n\(Preferences.shared.urlTemplate)"
        contentView.addSubviewWithAnchors(sourceLabel, top: note.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        var label = UILabel()
        label.text = "fromZoom:".localize()
        contentView.addSubviewWithAnchors(label, top: sourceLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        let segmentTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        
        let segSize = World.maxZoom - World.minZoom
        for i: Int in 0...segSize{
            minZoomControl.insertSegment(action: UIAction(){ action in
                self.enableDownload(false)
                self.minZoom = i + World.minZoom
                self.recalculateTiles()
            }, at: i, animated: false)
            minZoomControl.setTitle(String(i + World.minZoom), forSegmentAt: i)
        }
        minZoomControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        minZoomControl.selectedSegmentIndex = minZoom - World.minZoom
        contentView.addSubviewWithAnchors(minZoomControl, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        label = UILabel()
        label.text = "toZoom:".localize()
        contentView.addSubviewWithAnchors(label, top: minZoomControl.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        for i: Int in 0...segSize{
            maxZoomControl.insertSegment(action: UIAction(){ action in
                self.enableDownload(false)
                self.maxZoom = i + World.minZoom
                self.recalculateTiles()
            }, at: i, animated: false)
            maxZoomControl.setTitle(String(i + World.minZoom), forSegmentAt: i)
        }
        maxZoomControl.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        maxZoomControl.selectedSegmentIndex = maxZoom - World.minZoom
        contentView.addSubviewWithAnchors(maxZoomControl, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let allTilesLabel = UILabel()
        allTilesLabel.text = "allTilesForDownload".localize()
        contentView.addSubviewWithAnchors(allTilesLabel, top: maxZoomControl.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(allTilesValueLabel, top: maxZoomControl.bottomAnchor, leading: allTilesLabel.trailingAnchor, insets: defaultInsets)
        
        let existingTilesLabel = UILabel()
        existingTilesLabel.text = "existingTiles".localize()
        contentView.addSubviewWithAnchors(existingTilesLabel)
        existingTilesLabel.setAnchors(top: allTilesLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(existingTilesValueLabel, top: allTilesLabel.bottomAnchor, leading: existingTilesLabel.trailingAnchor, insets: defaultInsets)
        
        let tilesToLoadLabel = UILabel()
        tilesToLoadLabel.text = "tilesToLoad".localize()
        contentView.addSubviewWithAnchors(tilesToLoadLabel)
        tilesToLoadLabel.setAnchors(top: existingTilesLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(tilesToLoadValueLabel, top: existingTilesLabel.bottomAnchor, leading: tilesToLoadLabel.trailingAnchor, insets: defaultInsets)
        
        startButton.setTitle("startPreload".localize(), for: .normal)
        startButton.setTitleColor(.systemBlue, for: .normal)
        startButton.setTitleColor(.systemGray, for: .disabled)
        startButton.addAction(UIAction(){ action in
            self.startDownload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(startButton, top: tilesToLoadLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.centerXAnchor, insets: defaultInsets)
        
        cancelButton.setTitle("cancel".localize(), for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.setTitleColor(.systemGray, for: .disabled)
        cancelButton.addAction(UIAction(){ action in
            self.cancelDownload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(cancelButton, top: tilesToLoadLabel.bottomAnchor, leading: contentView.centerXAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        progressView.progress = 0
        contentView.addSubviewWithAnchors(progressView, top: startButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        
        var errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: progressView.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        errorsValueLabel.text = String(errors)
        contentView.addSubviewWithAnchors(errorsValueLabel, top: progressView.bottomAnchor, leading: errorsInfo.trailingAnchor, insets: defaultInsets)
        
        // watch
        
        let watchHeader = UILabel(header: "watchUploadArea".localize())
        contentView.addSubviewWithAnchors(watchHeader)
        watchHeader.setAnchors(top: errorsInfo.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        let watchInfo = UILabel(text: "watchUploadInfo".localize())
        watchInfo.numberOfLines = 0
        contentView.addSubviewWithAnchors(watchInfo)
        watchInfo.setAnchors(top: watchHeader.bottomAnchor, leading: contentView.leadingAnchor,trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        label = UILabel(text: "watchStatus".localizeWithColon())
        contentView.addSubviewWithAnchors(label)
        label.setAnchors(top: watchInfo.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(watchStatusLabel)
        watchStatusLabel.setAnchors(top: watchInfo.bottomAnchor, leading: label.trailingAnchor, insets: defaultInsets)
        
        startWatchUploadButton.setTitle("startWatchUpload".localize(), for: .normal)
        startWatchUploadButton.setTitleColor(.systemBlue, for: .normal)
        startWatchUploadButton.setTitleColor(.systemGray, for: .disabled)
        startWatchUploadButton.addAction(UIAction(){ action in
            self.startWatchUpload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(startWatchUploadButton, top: label.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        
        cancelWatchUploadButton.setTitle("cancel".localize(), for: .normal)
        cancelWatchUploadButton.setTitleColor(.systemBlue, for: .normal)
        cancelWatchUploadButton.setTitleColor(.systemGray, for: .disabled)
        cancelWatchUploadButton.addAction(UIAction(){ action in
            self.cancelWatchUpload()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(cancelWatchUploadButton, top: startWatchUploadButton.bottomAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        
        watchProgressView.progress = 0
        contentView.addSubviewWithAnchors(watchProgressView, top: cancelWatchUploadButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        
        errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: watchProgressView.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        uploadErrorsValueLabel.text = String(uploadErrors)
        contentView.addSubviewWithAnchors(uploadErrorsValueLabel, top: watchProgressView.bottomAnchor, leading: errorsInfo.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        
        enableZoomControls(true)
        enableDownload(false)
        updateConnectionStatus()
        recalculateTiles()
    }
    
    func reset(){
        allTiles = 0
        existingTiles = 0
        errors = 0
    }
    
    func updateValueViews(){
        allTilesValueLabel.text = String(allTiles)
        existingTilesValueLabel.text = String(existingTiles)
        tilesToLoadValueLabel.text = String(allTiles - existingTiles)
        errorsValueLabel.text = String(errors)
    }
    
    func updateSliderValue(){
        if allTiles != 0{
            progressView.progress = Float(existingTiles + errors)/Float(allTiles)
        }
    }
    
    func recalculateTiles(){
        if minZoom > maxZoom{
            reset()
            updateValueViews()
            updateSliderValue()
            enableDownload(false)
            enableUpload(false)
            return
        }
        let spinner = startSpinner()
        tiles.removeAll()
        if let region = mapRegion{
            reset()
            for zoom in region.tiles.keys{
                if zoom < minZoom || zoom > maxZoom{
                    continue
                }
                if let tileSet = region.tiles[zoom]{
                    for _ in tileSet.minX...tileSet.maxX{
                        for _ in tileSet.minY...tileSet.maxY{
                            allTiles += 1
                        }
                    }
                }
            }
            if allTiles > TilePreloadViewController.maxDownloadTiles{
                updateValueViews()
                updateSliderValue()
                enableDownload(false)
                enableDownload(false)
                stopSpinner(spinner)
                showError("tooManyTiles".localize(param: String(TilePreloadViewController.maxDownloadTiles)))
                return
            }
            for zoom in region.tiles.keys{
                if zoom < minZoom || zoom > maxZoom{
                    continue
                }
                if let tileSet = region.tiles[zoom]{
                    for x in tileSet.minX...tileSet.maxX{
                        for y in tileSet.minY...tileSet.maxY{
                            let tile = MapTile(zoom: zoom, x: x, y: y)
                            if tile.exists{
                                existingTiles += 1
                                continue
                            }
                            tiles.append(tile)
                        }
                    }
                }
            }
        }
        updateValueViews()
        updateSliderValue()
        enableDownload(tiles.count > 0)
        enableUpload(existingTiles == allTiles)
        stopSpinner(spinner)
    }
    
    func startDownload(){
        if tiles.isEmpty{
            return
        }
        if errors > 0{
            errors = 0
            updateValueViews()
            updateSliderValue()
        }
        enableDownload(false)
        enableUpload(false)
        enableZoomControls(false)
        downloadQueue = OperationQueue()
        downloadQueue!.name = "downloadQueue"
        downloadQueue!.maxConcurrentOperationCount = 2
        tiles.forEach { tile in
            let operation = TileDownloadOperation(tile: tile)
            operation.delegate = self
            downloadQueue!.addOperation(operation)
        }
    }
    
    func cancelDownload(){
        downloadQueue?.cancelAllOperations()
        reset()
        recalculateTiles()
        enableDownload(true)
        enableUpload(true)
        enableZoomControls(true)
    }

    func enableZoomControls(_ flag: Bool){
        minZoomControl.isEnabled = flag
        maxZoomControl.isEnabled = flag
    }
    
    func enableDownload(_ flag: Bool){
        startButton.isEnabled = flag
        cancelButton.isEnabled = !flag
    }
    
    // watch
    
    func updateWatchValueViews(){
        uploadErrorsValueLabel.text = String(uploadErrors)
    }
    
    func updateWatchSliderValue(){
        if watchTiles.count != 0{
            watchProgressView.progress = Float(uploadedTiles + uploadErrors)/Float(watchTiles.count)
        }
    }
    
    func recalculateWatchTiles(){
        watchTiles.removeAll()
        if let region = mapRegion{
            reset()
            for zoom in region.tiles.keys{
                if zoom < minZoom || zoom > maxZoom{
                    continue
                }
                if let tileSet = region.tiles[zoom]{
                    for x in tileSet.minX...tileSet.maxX{
                        for y in tileSet.minY...tileSet.maxY{
                            let tile = MapTile(zoom: zoom, x: x, y: y)
                            watchTiles.append(tile)
                        }
                    }
                }
            }
        }
    }
    
    func startWatchUpload(){
        if WatchConnector.shared.isWatchConnectionActivated{
            enableUpload(false)
            recalculateWatchTiles()
            uploadedTiles = 0
            uploadErrors = 0
            uploadQueue = OperationQueue()
            uploadQueue!.name = "uploadQueue"
            uploadQueue!.maxConcurrentOperationCount = 1
            Log.info("uploading \(watchTiles.count) tiles")
            watchTiles.forEach { tile in
                if let data = FileManager.default.readFile(url: tile.fileUrl){
                    let operation = TileUploadOperation(tile: tile, data:data)
                    operation.delegate = self
                    uploadQueue!.addOperation(operation)
                }
                else{
                    uploadWithError()
                }
            }
        }
    }
    
    func cancelWatchUpload(){
        uploadQueue?.cancelAllOperations()
        reset()
        recalculateWatchTiles()
        enableUpload(true)
    }
    
    func enableUpload(_ flag: Bool){
        startWatchUploadButton.isEnabled = flag
        cancelWatchUploadButton.isEnabled = !flag
    }
    
    func updateConnectionStatus(){
        watchStatusLabel.text = WatchConnector.shared.isWatchConnectionActivated ? "connected".localize() : "disconnected".localize()
        enableUpload(WatchConnector.shared.isWatchConnectionActivated)
    }
    
}

extension TilePreloadViewController: DownloadDelegate{
    
    func downloadSucceeded() {
        existingTiles += 1
        if existingTiles > allTiles{
            existingTiles = allTiles
        }
        updateValueViews()
        updateSliderValue()
        checkCompletion()
    }
    
    func downloadWithError() {
        errors += 1
        updateValueViews()
        updateSliderValue()
        checkCompletion()
    }
    
    private func checkCompletion(){
        if existingTiles + errors >= allTiles{
            enableZoomControls(true)
            enableUpload(existingTiles == allTiles)
            downloadQueue?.cancelAllOperations()
            downloadQueue = nil
        }
    }
    
}

extension TilePreloadViewController: UploadDelegate{
    
    func uploadSucceeded() {
        uploadedTiles += 1
        updateWatchValueViews()
        updateWatchSliderValue()
        checkWatchCompletion()
    }
    
    func uploadWithError() {
        uploadErrors += 1
        updateWatchValueViews()
        updateWatchSliderValue()
        checkWatchCompletion()
    }
    
    private func checkWatchCompletion(){
        if uploadedTiles + uploadErrors == watchTiles.count{
            enableUpload(true)
            uploadQueue?.cancelAllOperations()
            uploadQueue = nil
        }
    }
    
}
