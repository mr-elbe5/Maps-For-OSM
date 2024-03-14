/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol PlaceLayerViewDelegate{
    func showPlaceDetails(place: Place)
    func addImageToPlace(place: Place)
    func movePlaceToScreenCenter(place: Place)
    func deletePlace(place: Place)
    func showGroupDetails(group: PlaceGroup)
    func mergeGroup(group: PlaceGroup)
}

class PlaceLayerView: UIView {
    
    //MainViewController
    var delegate : PlaceLayerViewDelegate? = nil
    
    func setupMarkers(zoom: Int, offset: CGPoint, scale: CGFloat){
        //print("setupMarkers, zoom=\(zoom),offset=\(offset),scale=\(scale)")
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == World.maxZoom{
            for place in PlacePool.list{
                let marker = PlaceMarker(place: place)
                addSubview(marker)
                marker.menu = getMarkerMenu(marker: marker)
                marker.showsMenuAsPrimaryAction = true
            }
        }
        else{
            let planetDist = World.zoomScaleToWorld(from: zoom) * 10 // 10m at full zoom
            var groups = Array<PlaceGroup>()
            for location in PlacePool.list{
                var grouped = false
                for group in groups{
                    if group.isWithinRadius(location: location, radius: planetDist){
                        group.addLocation(location: location)
                        group.setCenter()
                        grouped = true
                    }
                }
                if !grouped{
                    let group = PlaceGroup()
                    group.addLocation(location: location)
                    group.setCenter()
                    groups.append(group)
                }
            }
            for group in groups{
                if group.places.count > 1{
                    let marker = PlaceGroupMarker(placeGroup: group)
                    addSubview(marker)
                    marker.menu = getGroupMarkerMenu(marker: marker)
                    marker.showsMenuAsPrimaryAction = true
                }
                else if let place = group.places.first{
                    let marker = PlaceMarker(place: place)
                    addSubview(marker)
                    marker.menu = getMarkerMenu(marker: marker)
                    marker.showsMenuAsPrimaryAction = true
                }
            }
            
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func getMarkerMenu(marker: PlaceMarker) -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showDetails".localize()){ action in
            self.delegate?.showPlaceDetails(place: marker.place)
        })
        actions.append(UIAction(title: "addImage".localize()){ action in
            self.delegate?.addImageToPlace(place: marker.place)
        })
        actions.append(UIAction(title: "moveToScreenCenter".localize()){ action in
            self.delegate?.movePlaceToScreenCenter(place: marker.place)
        })
        actions.append(UIAction(title: "delete".localize()){ action in
            self.delegate?.deletePlace(place: marker.place)
        })
        return UIMenu(title: marker.place.name, children: actions)
    }
    
    func getGroupMarkerMenu(marker: PlaceGroupMarker) -> UIMenu{
        var actions = Array<UIAction>()
        actions.append(UIAction(title: "showDetails".localize()){ action in
            self.delegate?.showGroupDetails(group: marker.placeGroup)
        })
        actions.append(UIAction(title: "mergeGroup".localize()){ action in
            self.delegate?.mergeGroup(group: marker.placeGroup)
        })
        return UIMenu(title: "group".localize(), children: actions)
    }
    
    func getMarker(location: Place) -> Marker?{
        for subview in subviews{
            if let marker = subview as? PlaceMarker, marker.place == location{
                return marker
            }
            if let marker = subview as? PlaceGroupMarker, marker.placeGroup.hasLocation(location: location){
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
            if let marker = subview as? PlaceMarker{
                marker.updatePosition(to: CGPoint(x: (marker.place.mapPoint.x - offset.x)*scale , y: (marker.place.mapPoint.y - offset.y)*scale))
            }
            else if let groupMarker = subview as? PlaceGroupMarker, let center = groupMarker.placeGroup.centerPlanetPosition{
                groupMarker.updatePosition(to: CGPoint(x: (center.x - offset.x)*scale , y: (center.y - offset.y)*scale))
            }
        }
    }
    
    func updatePlaceStatus(_ place: Place){
        if let marker = getMarker(location: place){
            marker.updateImage()
        }
    }
    
}



