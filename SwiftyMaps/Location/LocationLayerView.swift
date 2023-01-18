/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol LocationLayerViewDelegate{
    func showLocationDetails(location: Location)
    func addImageToLocation(location: Location)
    func moveLocationToScreenCenter(location: Location)
    func deleteLocation(location: Location)
    func showGroupDetails(group: LocationGroup)
    func mergeGroup(group: LocationGroup)
}

class LocationLayerView: UIView {
    
    //MainViewController
    var delegate : LocationLayerViewDelegate? = nil
    
    func setupMarkers(zoom: Int, offset: CGPoint, scale: CGFloat){
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == World.maxZoom{
            for location in LocationPool.list{
                let marker = LocationMarker(location: location)
                addSubview(marker)
                marker.menu = getMarkerMenu(marker: marker)
                marker.showsMenuAsPrimaryAction = true
            }
        }
        else{
            let planetDist = World.zoomScaleToWorld(from: zoom) * 10 // 10m at full zoom
            var groups = Array<LocationGroup>()
            for location in LocationPool.list{
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
                    addSubview(marker)
                    marker.menu = getGroupMarkerMenu(marker: marker)
                    marker.showsMenuAsPrimaryAction = true
                }
                else if let location = group.locations.first{
                    let marker = LocationMarker(location: location)
                    addSubview(marker)
                    marker.menu = getMarkerMenu(marker: marker)
                    marker.showsMenuAsPrimaryAction = true
                }
            }
            
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func getMarkerMenu(marker: LocationMarker) -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showDetails".localize()){ action in
            self.delegate?.showLocationDetails(location: marker.location)
        })
        actions.append(UIAction(title: "addImage".localize()){ action in
            self.delegate?.addImageToLocation(location: marker.location)
        })
        actions.append(UIAction(title: "moveToScreenCenter".localize()){ action in
            self.delegate?.moveLocationToScreenCenter(location: marker.location)
        })
        actions.append(UIAction(title: "delete".localize()){ action in
            self.delegate?.deleteLocation(location: marker.location)
        })
        return UIMenu(title: "", children: actions)
    }
    
    func getGroupMarkerMenu(marker: LocationGroupMarker) -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showDetails".localize()){ action in
            self.delegate?.showGroupDetails(group: marker.locationGroup)
        })
        actions.append(UIAction(title: "mergeGroup".localize()){ action in
            self.delegate?.mergeGroup(group: marker.locationGroup)
        })
        return UIMenu(title: "", children: actions)
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            $0 is Marker && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let offset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
        for subview in subviews{
            if let marker = subview as? LocationMarker{
                marker.updatePosition(to: CGPoint(x: (marker.location.mapPoint.x - offset.x)*scale , y: (marker.location.mapPoint.y - offset.y)*scale))
            }
            else if let groupMarker = subview as? LocationGroupMarker, let center = groupMarker.locationGroup.centerPlanetPosition{
                groupMarker.updatePosition(to: CGPoint(x: (center.x - offset.x)*scale , y: (center.y - offset.y)*scale))
            }
        }
    }
    
    func updateLocationState(_ location: Location){
        if let marker = getMarker(location: location){
            marker.updateImage()
        }
    }
    
}



