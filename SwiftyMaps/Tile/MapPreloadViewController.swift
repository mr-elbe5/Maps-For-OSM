/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class MapPreloadViewController: PopupScrollViewController{
    
    var mapRegion: TileRegion? = nil
    
    var downloadQueue : OperationQueue?
    
    var allTiles = 0
    var existingTiles = 0
    var errors = 0
    
    var tiles = [MapTile]()
    
    var allTilesValueLabel = UILabel()
    var existingTilesValueLabel = UILabel()
    var tilesToLoadValueLabel = UILabel()
    
    var startButton = UIButton()
    var cancelButton = UIButton()
    
    var loadedTilesSlider = UISlider()
    var errorsValueLabel = UILabel()
    
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
        let allTilesLabel = UILabel()
        allTilesLabel.text = "allTilesForDownload".localize()
        contentView.addSubview(allTilesLabel)
        allTilesLabel.setAnchors(top: note.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubview(allTilesValueLabel)
        allTilesValueLabel.setAnchors(top: note.bottomAnchor, leading: allTilesLabel.trailingAnchor, insets: defaultInsets)
        
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
        
        startButton.setTitle("start".localize(), for: .normal)
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
        errorsValueLabel.setAnchors(top: loadedTilesSlider.bottomAnchor, leading: errorsInfo.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        
        prepareDownload()
        updateValueViews()
        
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
    
    func prepareDownload(){
        tiles.removeAll()
        if let region = mapRegion{
            reset()
            for zoom in region.tiles.keys{
                if let tileSet = region.tiles[zoom]{
                    for x in tileSet.minX...tileSet.maxX{
                        for y in tileSet.minY...tileSet.maxY{
                            let tile = MapTile(zoom: zoom, x: x, y: y)
                            allTiles += 1
                            if let fileUrl = MapTiles.fileUrl(tile: tile){
                                if MapTiles.tileExists(url: fileUrl){
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
                let operation = TileDownloadOperation(tile: tile, urlTemplate: Preferences.instance.urlTemplate)
                operation.delegate = self
                self.downloadQueue!.addOperation(operation)
            }
        }
    }
    
    @objc func cancelDownload(){
        downloadQueue?.cancelAllOperations()
        reset()
        prepareDownload()
        updateValueViews()
        startButton.isEnabled = true
        cancelButton.isEnabled = false
    }
    
}

extension MapPreloadViewController: DownloadDelegate{
    
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
