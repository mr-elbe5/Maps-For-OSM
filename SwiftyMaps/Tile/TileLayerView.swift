/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class TileLayerView: UIView {
    
    var screenScale : CGFloat = 1.0
    
    // this is the factor from planet zoom: drawRect*scale=tileSize,
    // same as MapController.zoomScaleFromPlanet(to: zoom)
    private var _scaleToPlanet : CGFloat = 0.0
    var scaleToPlanet : CGFloat{
        get{
            _scaleToPlanet
        }
        set{
            if _scaleToPlanet  != newValue{
                _scaleToPlanet = newValue
                zoom = MapStatics.maxZoom - MapStatics.zoomLevelFromScale(scale: _scaleToPlanet)
            }
        }
    }
    var zoom : Int = 0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        screenScale = tileLayer.contentsScale
        tileLayer.tileSize = CGSize(width: MapStatics.tileSize.width*screenScale, height: MapStatics.tileSize.height*screenScale)
        //print("tile size = \(tileLayer.tileSize)")
        tileLayer.levelsOfDetail = MapStatics.maxZoom
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
        //print("draw \(rect)")
        let ctx = UIGraphicsGetCurrentContext()!
        scaleToPlanet = 1.0/ctx.ctm.a*screenScale
        drawTile(rect: rect)
    }
    
    func drawRect(ctx: CGContext, rect: CGRect, color: UIColor){
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(2.0/ctx.ctm.a)
        ctx.stroke(rect)
    }
    
    // rect is in contentSize = planetSize
    func drawTile(rect: CGRect){
        var x = Int(round(rect.minX / scaleToPlanet / MapStatics.tileSize.width))
        let y = Int(round(rect.minY / scaleToPlanet / MapStatics.tileSize.height))
        let currentMaxTiles = Int(MapStatics.zoomScale(at: zoom))
        // for infinite scroll
        while x >= currentMaxTiles{
            x -= currentMaxTiles
        }
        let tile = MapTiles.getTile(zoom: zoom, x: x, y: y)
        if let image = tile.image{
            //print("draw \(tile.string)")
            image.draw(in: rect)
            return
        }
        MapStatics.mapGearImage.draw(in: rect.scaleCenteredBy(0.25))
        MapTiles.loadTileImage(tile: tile){ data in
            //print("tile loaded \(tile.string)")
            if MapTiles.saveTile(tile: tile, data: data){
                //print("tile saved \(tile.string)")
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data){
                        tile.image = image
                        self.setNeedsDisplay(rect)
                    }
                }
            }
            else{
                print("error saving tile")
            }
        }
    }
    
}



