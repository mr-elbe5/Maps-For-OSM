/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

protocol TileCacheDelegate{
    func deleteTiles()
}

class TileCacheViewController: PopupScrollViewController{
    
    var mapRegion: TileRegion? = nil
    
    var downloadQueue : OperationQueue?
    
    var allTiles = 0
    var existingTiles = 0
    var errors = 0
    
    var tiles = [MapTile]()
    
    var minZoomSlider = UISlider()
    var minZoomLabel = UILabel()
    var maxZoomSlider = UISlider()
    var maxZoomLabel = UILabel()
    
    private var _minZoom : Int = World.minZoom
    var minZoom : Int{
        get{
            _minZoom
        }
        set{
            if _minZoom != newValue{
                _minZoom = newValue
                minZoomLabel.text = "\(_minZoom)"
            }
        }
    }
    private var _maxZoom : Int = World.maxZoom
    var maxZoom : Int{
        get{
            _maxZoom
        }
        set{
            if _maxZoom != newValue{
                _maxZoom = newValue
                maxZoomLabel.text = "\(_maxZoom)"
            }
        }
    }
    
    var allTilesValueLabel = UILabel()
    var existingTilesValueLabel = UILabel()
    var tilesToLoadValueLabel = UILabel()
    
    var startButton = UIButton()
    var cancelButton = UIButton()
    
    var loadedTilesSlider = UISlider()
    var errorsValueLabel = UILabel()
    
    var deleteButton = UIButton()
    
    var delegate : TileCacheDelegate? = nil
    
    override func loadView() {
        super.loadView()
        let header = UILabel()
        header.text = "mapPreload".localize()
        header.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5, weight: .bold)
        contentView.addSubview(header)
        header.setAnchors(top: contentView.topAnchor, insets: defaultInsets)
            .centerX(contentView.centerXAnchor)
        
        let note = UILabel()
        note.numberOfLines = 0
        note.lineBreakMode = .byWordWrapping
        note.text = "mapPreloadNote".localize()
        contentView.addSubview(note)
        note.setAnchors(top: header.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let typeLabel = UILabel()
        typeLabel.text = "\("currentMapType".localize()): \(AppState.instance.mapType)"
        contentView.addSubview(typeLabel)
        typeLabel.setAnchors(top: note.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        let sourceLabel = UILabel()
        sourceLabel.text = "\("currentTileSource".localize()): \(AppState.currentUrlTemplate)"
        contentView.addSubview(sourceLabel)
        sourceLabel.setAnchors(top: typeLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        minZoom = World.minZoom
        maxZoom = World.maxZoom
        let minFloat = Float(minZoom)
        let maxFloat = Float(maxZoom)
        let trackTintColor = UIColor.systemBlue
        
        var label = UILabel()
        label.text = "fromZoom:".localize()
        contentView.addSubview(label)
        label.setAnchors(top: sourceLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        minZoomSlider.minimumValue = minFloat
        minZoomSlider.maximumValue = maxFloat
        minZoomSlider.value = minFloat
        minZoomSlider.minimumTrackTintColor = trackTintColor
        minZoomSlider.maximumTrackTintColor = trackTintColor
        contentView.addSubview(minZoomSlider)
        minZoomSlider.setAnchors(top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        minZoomSlider.addTarget(self, action: #selector(minZoomChanged), for: .valueChanged)
        
        minZoomLabel = UILabel()
        minZoomLabel.text = "\(minZoom)"
        contentView.addSubview(minZoomLabel)
        minZoomLabel.setAnchors(top: minZoomSlider.bottomAnchor, insets: .zero).centerX(contentView.centerXAnchor)
        
        label = UILabel()
        label.text = "toZoom:".localize()
        contentView.addSubview(label)
        label.setAnchors(top: minZoomLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        maxZoomSlider.minimumValue = minFloat
        maxZoomSlider.maximumValue = maxFloat
        maxZoomSlider.value = maxFloat - 2
        maxZoomSlider.minimumTrackTintColor = trackTintColor
        maxZoomSlider.maximumTrackTintColor = trackTintColor
        contentView.addSubview(maxZoomSlider)
        maxZoomSlider.setAnchors(top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        maxZoomSlider.addTarget(self, action: #selector(maxZoomChanged), for: .valueChanged)
        
        maxZoomLabel = UILabel()
        maxZoomLabel.text = "\(maxZoom)"
        contentView.addSubview(maxZoomLabel)
        maxZoomLabel.setAnchors(top: maxZoomSlider.bottomAnchor, insets: .zero).centerX(contentView.centerXAnchor)
        
        let allTilesLabel = UILabel()
        allTilesLabel.text = "allTilesForDownload".localize()
        contentView.addSubview(allTilesLabel)
        allTilesLabel.setAnchors(top: maxZoomLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubview(allTilesValueLabel)
        allTilesValueLabel.setAnchors(top: maxZoomLabel.bottomAnchor, leading: allTilesLabel.trailingAnchor, insets: defaultInsets)
        
        let existingTilesLabel = UILabel()
        existingTilesLabel.text = "existingTiles".localize()
        contentView.addSubview(existingTilesLabel)
        existingTilesLabel.setAnchors(top: allTilesLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubview(existingTilesValueLabel)
        existingTilesValueLabel.setAnchors(top: allTilesLabel.bottomAnchor, leading: existingTilesLabel.trailingAnchor, insets: defaultInsets)
        
        let tilesToLoadLabel = UILabel()
        tilesToLoadLabel.text = "tilesToLoad".localize()
        contentView.addSubview(tilesToLoadLabel)
        tilesToLoadLabel.setAnchors(top: existingTilesLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubview(tilesToLoadValueLabel)
        tilesToLoadValueLabel.setAnchors(top: existingTilesLabel.bottomAnchor, leading: tilesToLoadLabel.trailingAnchor, insets: defaultInsets)
        
        startButton.setTitle("startPreload".localize(), for: .normal)
        startButton.setTitleColor(.systemBlue, for: .normal)
        startButton.setTitleColor(.systemGray, for: .disabled)
        startButton.addTarget(self, action: #selector(startDownload), for: .touchDown)
        contentView.addSubview(startButton)
        startButton.setAnchors(top: tilesToLoadLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.centerXAnchor, insets: defaultInsets)
        cancelButton.setTitle("cancel".localize(), for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.setTitleColor(.systemGray, for: .disabled)
        cancelButton.addTarget(self, action: #selector(cancelDownload), for: .touchDown)
        contentView.addSubview(cancelButton)
        cancelButton.setAnchors(top: tilesToLoadLabel.bottomAnchor, leading: contentView.centerXAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        loadedTilesSlider.minimumValue = 0
        loadedTilesSlider.maximumValue = Float(allTiles)
        loadedTilesSlider.value = 0
        contentView.addSubview(loadedTilesSlider)
        loadedTilesSlider.setAnchors(top: startButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        
        let errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubview(errorsInfo)
        errorsInfo.setAnchors(top: loadedTilesSlider.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        errorsValueLabel.text = String(errors)
        contentView.addSubview(errorsValueLabel)
        errorsValueLabel.setAnchors(top: loadedTilesSlider.bottomAnchor, leading: errorsInfo.trailingAnchor, insets: defaultInsets)
        
        deleteButton.setTitle("deleteAll".localize(), for: .normal)
        deleteButton.setTitleColor(.systemBlue, for: .normal)
        deleteButton.setTitleColor(.systemGray, for: .disabled)
        deleteButton.addTarget(self, action: #selector(deleteTiles), for: .touchDown)
        contentView.addSubview(deleteButton)
        deleteButton.setAnchors(top: errorsValueLabel.bottomAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets).centerX(contentView.centerXAnchor)
        
        recalculateTiles()
        
        if existingTiles == allTiles{
            startButton.isEnabled = false
            cancelButton.isEnabled = false
        }
        else{
            startButton.isEnabled = true
            cancelButton.isEnabled = false
        }
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
        loadedTilesSlider.maximumValue = Float(allTiles)
        updateSliderValue()
        updateSliderColor()
    }
    
    func updateSliderValue(){
        loadedTilesSlider.value = Float(existingTiles + errors)
    }
    
    func updateSliderColor(){
        loadedTilesSlider.thumbTintColor = (existingTiles + errors == allTiles) ? (errors > 0 ? .systemRed : .systemGreen) : .systemGray
    }
    
    func recalculateTiles(){
        tiles.removeAll()
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
                            allTiles += 1
                            if let fileUrl = TileCache.fileUrl(tile: tile){
                                if TileCache.tileExists(url: fileUrl){
                                    existingTiles += 1
                                    continue
                                }
                                tiles.append(tile)
                            }
                        }
                    }
                }
            }
        }
        updateValueViews()
    }
    
    @objc func minZoomChanged(){
        minZoomSlider.value = round(minZoomSlider.value)
        minZoom = Int(minZoomSlider.value)
        recalculateTiles()
    }
    
    @objc func maxZoomChanged(){
        maxZoomSlider.value = round(maxZoomSlider.value)
        maxZoom = Int(maxZoomSlider.value)
        recalculateTiles()
    }
    
    @objc func startDownload(){
        if tiles.isEmpty{
            return
        }
        showApprove(title: "confirmPreload".localize(), text: "preloadHint".localize()){
            if self.errors > 0{
                self.errors = 0
                self.updateValueViews()
            }
            self.startButton.isEnabled = false
            self.cancelButton.isEnabled = true
            self.downloadQueue = OperationQueue()
            self.downloadQueue!.name = "downloadQueue"
            self.downloadQueue!.maxConcurrentOperationCount = 2
            self.tiles.forEach { tile in
                let operation = TileDownloadOperation(tile: tile)
                operation.delegate = self
                self.downloadQueue!.addOperation(operation)
            }
        }
    }
    
    @objc func cancelDownload(){
        downloadQueue?.cancelAllOperations()
        reset()
        recalculateTiles()
        startButton.isEnabled = true
        cancelButton.isEnabled = false
    }
    
    @objc func deleteTiles(){
        delegate?.deleteTiles()
    }
    
}

extension TileCacheViewController: DownloadDelegate{
    
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
            updateSliderColor()
            startButton.isEnabled = errors > 0
            cancelButton.isEnabled = false
            downloadQueue?.cancelAllOperations()
            downloadQueue = nil
        }
    }
    
}
