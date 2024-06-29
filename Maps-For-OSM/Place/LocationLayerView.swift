/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI
import E5MapData

protocol LocationLayerDelegate{
    func showLocationDetails(location: Location)
    func deleteLocation(location: Location)
    func showGroupDetails(group: LocationGroup)
}

class LocationLayerView: UIView {
    
    var locations = LocationList()
    
    var delegate: LocationLayerDelegate? = nil
    
    func updateLocations(){
        locations = AppData.shared.locations.filteredLocations
    }
    
    func setupMarkers(zoom: Int, offset: CGPoint, scale: CGFloat){
        //Log.debug("setupMarkers, zoom=\(zoom),offset=\(offset),scale=\(scale)")
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == World.maxZoom{
            for location in locations{
                let marker = LocationMarker(location: location)
                marker.addAction(UIAction{ action in
                    self.delegate?.showLocationDetails(location: marker.location)
                }, for: .touchDown)
                addSubview(marker)
                //marker.menu = getMarkerMenu(marker: marker)
                //marker.showsMenuAsPrimaryAction = true
            }
        }
        else{
            let planetDist = World.zoomScaleToWorld(from: zoom) * 10 // 10m at full zoom
            var groups = Array<LocationGroup>()
            for location in locations{
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
                    let marker = LocationGroupMarker(placeGroup: group)
                    marker.addAction(UIAction{ action in
                        self.delegate?.showGroupDetails(group: group)
                    }, for: .touchDown)
                    addSubview(marker)
                }
                else if let location = group.locations.first{
                    let marker = LocationMarker(location: location)
                    marker.addAction(UIAction{ action in
                        location.assertPlacemark()
                        self.delegate?.showLocationDetails(location: location)
                    }, for: .touchDown)
                    addSubview(marker)
                }
            }
            
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func updateMarker(for location: Location){
        if let marker = getMarker(location: location){
            marker.updateImage()
        }
    }
    
    func getMarker(location: Location) -> Marker?{
        for subview in subviews{
            if let marker = subview as? LocationMarker, marker.location.equals(location){
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
        let offset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        for subview in subviews{
            if let marker = subview as? LocationMarker{
                marker.updatePosition(to: CGPoint(x: (marker.location.mapPoint.x - offset.x)*scale , y: (marker.location.mapPoint.y - offset.y)*scale))
            }
            else if let groupMarker = subview as? LocationGroupMarker, let center = groupMarker.placeGroup.centerPlanetPosition{
                groupMarker.updatePosition(to: CGPoint(x: (center.x - offset.x)*scale , y: (center.y - offset.y)*scale))
            }
        }
    }
    
    func updatePlaceStatus(_ location: Location){
        if let marker = getMarker(location: location){
            marker.updateImage()
        }
    }
    
}



