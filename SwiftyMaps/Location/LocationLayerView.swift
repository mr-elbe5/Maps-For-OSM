/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol LocationLayerViewDelegate{
    func showLocationDetails(place: Location)
}

class LocationLayerView: UIView {
    
    //MainViewController
    var delegate : LocationLayerViewDelegate? = nil
    
    func setupMarkers(zoom: Int, offset: CGPoint, scale: CGFloat){
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == World.maxZoom{
            for place in Locations.list{
                let marker = LocationMarker(place: place)
                addSubview(marker)
                marker.addTarget(self, action: #selector(showLocationDetails), for: .touchDown)
            }
        }
        else{
            let planetDist = World.zoomScaleToWorld(from: zoom) * 10 // 10m at full zoom
            var groups = Array<LocationGroup>()
            for place in Locations.list{
                var grouped = false
                for group in groups{
                    if group.isWithinRadius(location: place, radius: planetDist){
                        group.addLocation(location: place)
                        group.setCenter()
                        grouped = true
                    }
                }
                if !grouped{
                    let group = LocationGroup()
                    group.addLocation(location: place)
                    group.setCenter()
                    groups.append(group)
                }
            }
            for group in groups{
                if group.locations.count > 1{
                    let marker = LocationGroupMarker(placeGroup: group)
                    addSubview(marker)
                }
                else if let place = group.locations.first{
                    let marker = LocationMarker(place: place)
                    addSubview(marker)
                    marker.addTarget(self, action: #selector(showLocationDetails), for: .touchDown)
                }
            }
            
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func getMarker(location: Location) -> Marker?{
        for subview in subviews{
            if let marker = subview as? LocationMarker, marker.place == location{
                return marker
            }
            if let marker = subview as? LocationGroupMarker, marker.placeGroup.hasLocation(location: location){
                return marker
            }
        }
        return nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            $0 is Marker && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let offset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
        for subview in subviews{
            if let marker = subview as? LocationMarker{
                marker.updatePosition(to: CGPoint(x: (marker.place.mapPoint.x - offset.x)*scale , y: (marker.place.mapPoint.y - offset.y)*scale))
            }
            else if let groupPin = subview as? LocationGroupMarker, let center = groupPin.placeGroup.centerPlanetPosition{
                groupPin.updatePosition(to: CGPoint(x: (center.x - offset.x)*scale , y: (center.y - offset.y)*scale))
            }
        }
    }
    
    func updateLocationState(_ location: Location){
        if let marker = getMarker(location: location){
            marker.updateImage()
        }
    }
    
    @objc func showLocationDetails(_ sender: AnyObject){
        if let marker = sender as? LocationMarker{
            delegate?.showLocationDetails(place: marker.place)
        }
    }
    
}



