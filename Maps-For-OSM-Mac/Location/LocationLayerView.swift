/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import E5Data
import E5MapData


protocol LocationLayerDelegate{
    func showLocationDetails(_ location: Location)
    func showLocationGroupDetails(_ locationGroup: LocationGroup)
}

protocol DragDelegate{
    func mouseDragged(dx: CGFloat, dy: CGFloat)
}

class LocationLayerView: NSView {
    
    var delegate: LocationLayerDelegate? = nil
    var dragDelegate: DragDelegate? = nil
    
    override var isFlipped: Bool{
        true
    }
    
    override func mouseDragged(with event: NSEvent) {
        if event.type == .leftMouseDragged{
            dragDelegate?.mouseDragged(dx: event.deltaX, dy: event.deltaY)
        }
    }
    
    func setupMarkers(zoom: Int, scale: CGFloat){
        //Log.debug("setupMarkers, zoom=\(zoom),offset=\(offset),scale=\(scale)")
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == World.maxZoom{
            for location in AppData.shared.locations{
                let marker = LocationMarker(location: location, target: self, action: #selector(showLocationDetails))
                addSubview(marker)
            }
        }
        else{
            let planetDist = World.zoomScaleToWorld(from: zoom) * 10 // 10m at full zoom
            var groups = Array<LocationGroup>()
            for location in AppData.shared.locations{
                var grouped = false
                for group in groups{
                    if group.isWithinRadius(location: location, radius: planetDist){
                        group.addLocation(location: location)
                        group.setCenter()
                        grouped = true
                    }
                }
                if !grouped{
                    let group = LocationGroup()
                    group.addLocation(location: location)
                    group.setCenter()
                    groups.append(group)
                }
            }
            for group in groups{
                if group.locations.count > 1{
                    let marker = LocationGroupMarker(locationGroup: group, target: self, action: #selector(showGroupDetails))
                    addSubview(marker)
                }
                else if let location = group.locations.first{
                    let marker = LocationMarker(location: location, target: self, action: #selector(showLocationDetails))
                    addSubview(marker)
                }
            }
            
        }
        updatePosition(scale: scale)
    }
    
    func updateMarker(for location: Location){
        if let marker = getMarker(location: location){
            marker.updateImage()
        }
    }
    
    func getMarker(location: Location) -> Marker?{
        for subview in subviews{
            if let marker = subview as? LocationMarker, marker.location == location{
                return marker
            }
            if let marker = subview as? LocationGroupMarker, marker.locationGroup.hasLocation(location: location){
                return marker
            }
        }
        return nil
    }
    
    func updatePosition(scale: CGFloat){
        for subview in subviews{
            if let marker = subview as? LocationMarker{
                marker.updatePosition(to: CGPoint(x: (marker.location.mapPoint.x)*scale , y: (marker.location.mapPoint.y)*scale))
            }
            else if let groupMarker = subview as? LocationGroupMarker, let center = groupMarker.locationGroup.centerPlanetPosition{
                groupMarker.updatePosition(to: CGPoint(x: (center.x)*scale , y: (center.y)*scale))
            }
        }
    }
    
    func updateLocationStatus(_ location: Location){
        if let marker = getMarker(location: location){
            marker.updateImage()
        }
    }
    
    @objc func showLocationDetails(sender: AnyObject?){
        if let marker = sender as? LocationMarker{
            delegate?.showLocationDetails(marker.location)
        }
    }
    
    @objc func showGroupDetails(sender: AnyObject?){
        if let marker = sender as? LocationGroupMarker{
            delegate?.showLocationGroupDetails(marker.locationGroup)
        }
    }
    
}




