/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

class TileLayerView: UIView {
    
    var mapGearImage = UIImage(named: "gear.grey")
    
    var pointToPixelsFactor : CGFloat = 1.0
    
    // this is the factor from planet zoom: drawRect*scale=tileSize,
    // same as MapController.zoomScaleFromPlanet(to: zoom)
    private var _scaleToPlanet : CGFloat = 0.0
    var scaleToPlanet : CGFloat{
        get{
            _scaleToPlanet
        }
        set{
            if _scaleToPlanet != newValue{
                _scaleToPlanet = newValue
                zoom = World.maxZoom - World.zoomLevelFromScale(scale: _scaleToPlanet)
            }
        }
    }
    
    var zoom : Int = 0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        pointToPixelsFactor = tileLayer.contentsScale
        tileLayer.tileSize = CGSize(width: World.tileExtent*pointToPixelsFactor, height: World.tileExtent*pointToPixelsFactor)
        tileLayer.levelsOfDetail = World.maxZoom
        tileLayer.levelsOfDetailBias = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CATiledLayer.self
    }
    
    var tileLayer: CATiledLayer {
        return self.layer as! CATiledLayer
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        scaleToPlanet = 1.0/ctx.ctm.a*pointToPixelsFactor
        drawTile(rect: rect)
    }
    
    private func getTileData(rect: CGRect) -> MapTileData{
        var x = Int(round(rect.minX / scaleToPlanet / World.tileSize.width))
        let currentMaxTiles = Int(World.zoomScale(at: zoom))
        // for infinite scroll
        while x >= currentMaxTiles{
            x -= currentMaxTiles
        }
        let y = Int(round(rect.minY / scaleToPlanet / World.tileSize.height))
        return MapTileData(zoom: zoom, x: x, y: y)
    }
    
    func drawRect(ctx: CGContext, rect: CGRect, color: UIColor){
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(2.0/ctx.ctm.a)
        ctx.stroke(rect)
    }
    
    // rect is in contentSize = planetSize
    func drawTile(rect: CGRect){
        let tile = MapTile.getTile(data: getTileData(rect: rect))
        if let image = tile.image{
            image.draw(in: rect)
            return
        }
        mapGearImage?.draw(in: rect.scaleCenteredBy(0.25))
        TileProvider.shared.loadTileImage(tile: tile, template: Preferences.shared.urlTemplate){ success in
            if success{
                DispatchQueue.main.async {
                    self.setNeedsDisplay(rect)
                }
            }
            else{
                Log.error("TileLayerView could not load tile \(tile.shortDescription)")
            }
        }
    }
    
    func refresh(){
        tileLayer.setNeedsDisplay()
    }
    
}



