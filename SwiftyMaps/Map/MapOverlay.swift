//
//  MapOverlay.swift
//  SwiftyMaps
//
//  Created by Michael Rönnau on 17.09.21.
//

import Foundation
import MapKit

protocol MapOverlayDelegate{
    func zoomChanged(zoom: Int)
}

class MapTileOverlay : MKTileOverlay{
    
    var zoom = 0
    var delegate : MapOverlayDelegate? = nil
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url = url(forTilePath: path)
        if path.z != zoom{
            zoom = path.z
            delegate?.zoomChanged(zoom: zoom)
        }
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30.0)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var statusCode = 0
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if let error = error {
                print("error loading map tile from \(url.path), error:\(error.localizedDescription)")
                result(nil, error)
            } else if (statusCode == 200 ){
                result(data, nil)
            }
            else{
                print("error loading map tile from \(url.path), statusCode=\(statusCode)")
                result(nil, MapError.load)
            }
        }
        task.resume()
    }
}

class MapTileOverlayRenderer : MKTileOverlayRenderer{
    
    /*override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        print("drawing tile")
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }*/
}
