/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5Data


class TileLayerView: NSView {
    
    var mapGearImage = NSImage(named: "gear.grey")
    
    var pointToPixelsFactor : CGFloat = 1.0
    
    override var isFlipped: Bool{
        return true
    }
    
    override init(frame: NSRect){
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeBackingLayer() -> CALayer {
        let layer = CATiledLayer()
        pointToPixelsFactor = layer.contentsScale
        layer.tileSize = CGSize(width: World.tileExtent*pointToPixelsFactor, height: World.tileExtent*pointToPixelsFactor)
        layer.levelsOfDetail = World.maxZoom
        layer.levelsOfDetailBias = 0
        return layer
    }
    
    override func draw(_ dirtyRect: CGRect) {
        //Log.debug("dirtyRect: \(dirtyRect)")
        //drawRect(ctx: NSGraphicsContext.current!.cgContext, rect: dirtyRect, color: .red)
        drawTile(rect: dirtyRect)
    }
    
    private func getTileData(rect: CGRect) -> MapTileData{
        let x = Int(round(rect.minX / World.tileSize.width))
        let y = Int(round(rect.minY / World.tileSize.height))
        return MapTileData(zoom: AppState.shared.zoom, x: x, y: y)
    }
    
    func drawRect(ctx: CGContext, rect: CGRect, color: NSColor){
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(2.0/ctx.ctm.a)
        ctx.stroke(rect)
        let tileData = getTileData(rect: rect)
        let str = "zoom:\(tileData.zoom), x:\(tileData.x), y:\(tileData.y)"
        str.draw(at: rect.origin)
    }
    
    // rect is in contentSize = planetSize
    func drawTile(rect: CGRect){
        let tileData = getTileData(rect: rect)
        let tile = MapTile.getTile(data: tileData)
        if let image = tile.image{
            image.draw(in: rect)
            return
        }
        mapGearImage?.draw(in: rect.scaleCenteredBy(0.25))
        TileProvider.shared.loadTileImage(tile: tile, template: Preferences.shared.urlTemplate){ success in
            if success{
                DispatchQueue.main.async {
                    self.layer?.setNeedsDisplay(rect)
                }
            }
            else{
                Log.error("TileLayerView could not load tile \(tile.shortDescription)")
            }
        }
    }
    
    func refresh(){
        layer?.setNeedsDisplay()
    }
    
}



