/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CommonBasics
import IOSBasics

class PreloadViewController: PopupScrollViewController{
    
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
    
    override func loadView() {
        title = "mapPreload".localize()
        super.loadView()
        
        let note = UILabel()
        note.numberOfLines = 0
        note.lineBreakMode = .byWordWrapping
        note.text = "mapPreloadNote".localize()
        contentView.addSubviewWithAnchors(note, top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
        
        let sourceLabel = UILabel()
        sourceLabel.text = "\("currentTileSource:".localize()) \(Preferences.shared.urlTemplate)"
        contentView.addSubviewWithAnchors(sourceLabel, top: note.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        minZoom = World.minZoom
        maxZoom = World.maxZoom
        let minFloat = Float(minZoom)
        let maxFloat = Float(maxZoom)
        let trackTintColor = UIColor.systemBlue
        
        var label = UILabel()
        label.text = "fromZoom:".localize()
        contentView.addSubviewWithAnchors(label, top: sourceLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        minZoomSlider.minimumValue = minFloat
        minZoomSlider.maximumValue = maxFloat
        minZoomSlider.value = minFloat
        minZoomSlider.minimumTrackTintColor = trackTintColor
        minZoomSlider.maximumTrackTintColor = trackTintColor
        contentView.addSubviewWithAnchors(minZoomSlider, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        minZoomSlider.addAction(UIAction(){ action in
            self.minZoomSlider.value = round(self.minZoomSlider.value)
            self.minZoom = Int(self.minZoomSlider.value)
            self.recalculateTiles()
        }, for: .valueChanged)
        
        minZoomLabel = UILabel()
        minZoomLabel.text = "\(minZoom)"
        contentView.addSubviewWithAnchors(minZoomLabel, top: minZoomSlider.bottomAnchor, insets: .zero).centerX(contentView.centerXAnchor)
        
        label = UILabel()
        label.text = "toZoom:".localize()
        contentView.addSubviewWithAnchors(label, top: minZoomLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        
        maxZoomSlider.minimumValue = minFloat
        maxZoomSlider.maximumValue = maxFloat
        maxZoomSlider.value = maxFloat - 2
        maxZoomSlider.minimumTrackTintColor = trackTintColor
        maxZoomSlider.maximumTrackTintColor = trackTintColor
        contentView.addSubviewWithAnchors(maxZoomSlider, top: label.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        maxZoomSlider.addAction(UIAction(){ action in
            self.maxZoomSlider.value = round(self.maxZoomSlider.value)
            self.maxZoom = Int(self.maxZoomSlider.value)
            self.recalculateTiles()
        }, for: .touchDown)
        
        maxZoomLabel = UILabel()
        maxZoomLabel.text = "\(maxZoom)"
        contentView.addSubviewWithAnchors(maxZoomLabel, top: maxZoomSlider.bottomAnchor, insets: .zero).centerX(contentView.centerXAnchor)
        
        let allTilesLabel = UILabel()
        allTilesLabel.text = "allTilesForDownload".localize()
        contentView.addSubviewWithAnchors(allTilesLabel, top: maxZoomLabel.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        contentView.addSubviewWithAnchors(allTilesValueLabel, top: maxZoomLabel.bottomAnchor, leading: allTilesLabel.trailingAnchor, insets: defaultInsets)
        
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
        
        loadedTilesSlider.minimumValue = 0
        loadedTilesSlider.maximumValue = Float(allTiles)
        loadedTilesSlider.value = 0
        contentView.addSubviewWithAnchors(loadedTilesSlider, top: startButton.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: doubleInsets)
        
        let errorsInfo = UILabel()
        errorsInfo.text = "unloadedTiles".localize()
        contentView.addSubviewWithAnchors(errorsInfo, top: loadedTilesSlider.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
        errorsValueLabel.text = String(errors)
        contentView.addSubviewWithAnchors(errorsValueLabel, top: loadedTilesSlider.bottomAnchor, leading: errorsInfo.trailingAnchor, bottom: contentView.bottomAnchor, insets: defaultInsets)
        
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
    
    override func setupHeaderView(headerView: UIView){
        super.setupHeaderView(headerView: headerView)
        let infoButton = UIButton().asIconButton("info")
        headerView.addSubviewWithAnchors(infoButton, top: headerView.topAnchor, trailing: closeButton.leadingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        infoButton.addAction(UIAction(){ action in
            let controller = PreloadInfoViewController()
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }, for: .touchDown)
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
    }
    
    func startDownload(){
        if tiles.isEmpty{
            return
        }
        if errors > 0{
            errors = 0
            updateValueViews()
        }
        startButton.isEnabled = false
        cancelButton.isEnabled = true
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
        startButton.isEnabled = true
        cancelButton.isEnabled = false
    }
    
}

extension PreloadViewController: DownloadDelegate{
    
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
