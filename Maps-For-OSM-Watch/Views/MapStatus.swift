import Foundation
import CoreLocation
import SwiftUI

typealias TileRow = [TileData]
typealias TileGrid = [TileRow]

@Observable class MapStatus: NSObject{
    
    static var shared = MapStatus()
    
    var currentCoordinate: CLLocationCoordinate2D? = nil
    var centerCoordinate: CLLocationCoordinate2D? = nil
    var direction: CLLocationDirection = 0
    
    var screenSize = WKInterfaceDevice.current().screenBounds
    let tileExtent: CGFloat = World.tileExtent
    var gridWidth: Int = 1
    var gridHeight: Int = 1
    var tileGrid: TileGrid = []
    
    var centerTileX: Int = 0
    var centerTileY: Int = 0
    var horzExtraTiles: Int = 0
    var vertExtraTiles: Int = 0
    var tileOffsetX: CGFloat = 0
    var tileOffsetY: CGFloat = 0
    var currentLocationOffset: CGSize = .zero
    
    var zoom: Int = Preferences.startZoom
    
    private var downScaleFromWorld = World.zoomScaleFromWorld(to: Preferences.startZoom)
    private var scaledWorldCenterX = 0.0
    private var scaledWorldCenterY = 0.0
    
    // tile 16/34530/21183
    
    override init(){
        super.init()
        currentCoordinate = LocationManager.shared.location?.coordinate
        centerCoordinate = LocationManager.shared.location?.coordinate
        horzExtraTiles = Int(floor(screenSize.width/2 / tileExtent)) + 2
        vertExtraTiles = Int(floor(screenSize.height/2 / tileExtent)) + 2
        gridWidth = 2 * horzExtraTiles + 1
        gridHeight = 2 * vertExtraTiles + 1
        //Log.debug("grid size = \(gridWidth) x \(gridHeight)")
        for _ in 0..<gridHeight {
            var row = TileRow()
            for _ in 0..<gridWidth {
                row.append(TileData(zoom: 0, tileX: 0, tileY: 0))
            }
            tileGrid.append(row)
        }
    }
    
    private func setCenterCoordinate(_ coordinate: CLLocationCoordinate2D){
        self.centerCoordinate = coordinate
    }
    
    private func setCurrentCoordinate(_ coordinate: CLLocationCoordinate2D){
        self.currentCoordinate = coordinate
        updateWorldValues()
    }
    
    @discardableResult
    private func updateWorldValues() -> Bool{
        if let coordinate = centerCoordinate{
            downScaleFromWorld = World.zoomScaleFromWorld(to: zoom)
            scaledWorldCenterX = World.scaledX(coordinate.longitude, downScale: downScaleFromWorld)
            scaledWorldCenterY = World.scaledY(coordinate.latitude, downScale: downScaleFromWorld)
            return true
        }
        return false
    }
    
    func updateTiles(){
        let centerTileLeft = scaledWorldCenterX - tileExtent/2
        let centerTileTop = scaledWorldCenterY - tileExtent/2
        centerTileX = Int(floor(centerTileLeft / tileExtent))
        centerTileY = Int(floor(centerTileTop / tileExtent))
        //print("centerTile \(centerTileX), \(centerTileY)")
        
        // diff of tile edge to center plus offset to tile center
        tileOffsetX = (Double(centerTileX)*tileExtent - scaledWorldCenterX + tileExtent/2)
        tileOffsetY = (Double(centerTileY)*tileExtent - scaledWorldCenterY + tileExtent/2)
        //print("offset: \(tileOffsetX),\(tileOffsetY)")
        updateTileGrid()
    }
    
    private func updateTileGrid(){
        //print("update grid")
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                let currentTile = tileGrid[y][x]
                let newTileX = centerTileX - horzExtraTiles + x
                let newTileY = centerTileY - vertExtraTiles + y
                if currentTile.zoom != zoom || currentTile.tileX != newTileX || currentTile.tileY != newTileY{
                    //print("changing tile")
                    let tile = TileData(zoom: zoom, tileX: newTileX, tileY: newTileY)
                    TileProvider.shared.assertTileImage(tile: tile)
                    tileGrid[y][x] = tile
                }
            }
        }
    }
    
    func getTile(x: Int, y: Int) -> TileData?{
        guard x >= 0 && x < tileGrid[0].count && y >= 0 && y < tileGrid.count else {
            print("out of range: \(x), \(y)")
            return nil }
        return tileGrid[y][x]
    }
    
    func updateCurrentLocationOffset(){
        if let coordinate = currentCoordinate{
            let scaledWorldX = World.scaledX(coordinate.longitude, downScale: downScaleFromWorld)
            let scaledWorldY = World.scaledY(coordinate.latitude, downScale: downScaleFromWorld)
            let xOffset = scaledWorldCenterX - scaledWorldX
            let yOffset = scaledWorldCenterY - scaledWorldY
            currentLocationOffset = CGSize(width: -xOffset, height: -yOffset)
        }
    }
    
    func moveBy(offset: CGSize){
        scaledWorldCenterX -= offset.width
        scaledWorldCenterY -= offset.height
        setCenterCoordinate(World.coordinate(scaledX: scaledWorldCenterX, scaledY: scaledWorldCenterY, downScale: downScaleFromWorld))
        //print("moving to coordinate \(centerCoordinate)")
        updateCurrentLocationOffset()
        updateTiles()
    }
    
    func zoomTo(_ zoom: Int){
        if zoom <= World.maxZoom, zoom >= 0{
            self.zoom = zoom
            updateWorldValues()
            updateCurrentLocationOffset()
            updateTiles()
        }
    }
    
    func zoomIn(){
        if zoom < World.maxZoom{
            zoom += 1
            updateWorldValues()
            updateCurrentLocationOffset()
            updateTiles()
        }
    }
    
    func zoomOut(){
        if zoom > 0{
            zoom -= 1
            updateWorldValues()
            updateCurrentLocationOffset()
            updateTiles()
        }
    }
    
}


