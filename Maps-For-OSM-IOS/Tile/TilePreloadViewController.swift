/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI


class TilePreloadViewController: NavScrollViewController{
    
    static var maxDownloadTiles = 5000
    
    var mapRegion: TileRegion? = nil
    
    var downloadQueue : OperationQueue?
    
    var allTiles = 0
    var existingTiles = 0
    var errors = 0
    
    var tiles = [MapTile]()
    
    var minZoomControl = UISegmentedControl()
    var maxZoomControl = UISegmentedControl()
    
    var minZoom : Int = World.minZoom
    var maxZoom : Int = World.maxZoom
    
    var allTilesValueLabel = UILabel()
    var existingTilesValueLabel = UILabel()
    var tilesToLoadValueLabel = UILabel()
    
    let calculateButton = UIButton()
    var startButton = UIButton()
    var cancelButton = UIButton()
    
    var progressView = UIProgressView()
    
    var errorsValueLabel = UILabel()
    
    var deleteButton = UIButton()
    
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
    }
    
    override func loadScrollableSubviews() {
        let note = UILabel()
        note.numberOfLines = 0
        note.lineBreakMode = .byWordWrapping
        note.text = "mapPreloadNote".localize()
        contentView.addSubviewWithAnchors(note, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let sourceLabel = UILabel()
        sourceLabel.text = "\("currentTileSource:".localize())\n\(Preferences.shared.urlTemplate)"
        contentView.addSubviewWithAnchors(sourceLabel, top: note.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        var label = UILabel()
        label.text = "fromZoom:".localize()
        contentView.addSubviewWithAnchors(label, top: sourceLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        let segSize = World.maxZoom - World.minZoom
        for i: Int in 0...segSize{
            minZoomControl.insertSegment(action: UIAction(){ action in
                self.enableCalculation(true)
                self.enableDownload(false)
                self.minZoom = i + World.minZoom
            }, at: i, animated: false)
            minZoomControl.setTitle(String(i + World.minZoom), forSegmentAt: i)
        }
        minZoomControl.selectedSegmentIndex = 0
        contentView.addSubviewWithAnchors(minZoomControl, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        label = UILabel()
        label.text = "toZoom:".localize()
        contentView.addSubviewWithAnchors(label, top: minZoomControl.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        for i: Int in 0...segSize{
            maxZoomControl.insertSegment(action: UIAction(){ action in
                self.enableCalculation(true)
                self.enableDownload(false)
                self.maxZoom = i + World.minZoom
            }, at: i, animated: false)
            maxZoomControl.setTitle(String(i + World.minZoom), forSegmentAt: i)
        }
        maxZoomControl.selectedSegmentIndex = 0
        contentView.addSubviewWithAnchors(maxZoomControl, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        calculateButton.setTitle("recalculateTiles".localize(), for: .normal)
        calculateButton.setTitleColor(.systemBlue, for: .normal)
        calculateButton.setTitleColor(.systemGray, for: .disabled)
        calculateButton.addAction(UIAction(){ action in
            self.recalculateTiles()
        }, for: .touchDown)
        contentView.addSubviewWithAnchors(calculateButton, top: maxZoomControl.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let allTilesLabel = UILabel()
        allTilesLabel.text = "allTilesForDownload".localize()
        contentView.addSubviewWithAnchors(allTilesLabel, top: calculateButton.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(allTilesValueLabel, top: calculateButton.bottomAnchor, leading: allTilesLabel.trailingAnchor, insets: defaultInsets)
        
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
        
        let errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: progressView.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        errorsValueLabel.text = String(errors)
        contentView.addSubviewWithAnchors(errorsValueLabel, top: progressView.bottomAnchor, leading: errorsInfo.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        
        enableCalculation(true)
        enableDownload(false)
        
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
        updateSliderValue()
    }
    
    func updateSliderValue(){
        progressView.progress = Float(existingTiles + errors)/Float(allTiles)
    }
    
    func recalculateTiles(){
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
        enableDownload(true)
        stopSpinner(spinner)
    }
    
    func startDownload(){
        if tiles.isEmpty{
            return
        }
        if errors > 0{
            errors = 0
            updateValueViews()
        }
        enableDownload(false)
        enableCalculation(false)
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
        enableDownload(true)
        enableCalculation(true)
    }
    
    func enableCalculation(_ flag: Bool){
        calculateButton.isEnabled = flag
    }
    
    func enableDownload(_ flag: Bool){
        startButton.isEnabled = flag
        cancelButton.isEnabled = !flag
    }
    
}

extension TilePreloadViewController: DownloadDelegate{
    
    func downloadSucceeded() {
        existingTiles += 1
        updateSliderValue()
        self.existingTilesValueLabel.text = String(self.existingTiles)
        self.tilesToLoadValueLabel.text = String(self.allTiles - self.existingTiles)
        checkCompletion()
    }
    
    func downloadWithError() {
        errors += 1
        errorsValueLabel.text = String(self.errors)
        updateSliderValue()
        checkCompletion()
    }
    
    private func checkCompletion(){
        if existingTiles + errors == allTiles{
            enableDownload(true)
            downloadQueue?.cancelAllOperations()
            downloadQueue = nil
        }
    }
    
}
