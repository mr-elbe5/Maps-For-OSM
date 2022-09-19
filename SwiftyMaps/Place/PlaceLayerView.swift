/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol PlaceLayerViewDelegate{
    func showPlaceDetails(place: Place)
}

class PlaceLayerView: UIView {
    
    //MainViewController
    var delegate : PlaceLayerViewDelegate? = nil
    
    func setupPins(zoom: Int, offset: CGPoint, scale: CGFloat){
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == World.maxZoom{
            for place in Places.list{
                let pin = PlacePin(place: place)
                addSubview(pin)
                pin.addTarget(self, action: #selector(showPlaceDetails), for: .touchDown)
            }
        }
        else{
            let planetDist = World.zoomScaleToWorld(from: zoom) * 10 // 10m at full zoom
            var groups = Array<PlaceGroup>()
            for place in Places.list{
                var grouped = false
                for group in groups{
                    if group.isWithinRadius(place: place, radius: planetDist){
                        group.addPlace(place: place)
                        group.setCenter()
                        grouped = true
                    }
                }
                if !grouped{
                    let group = PlaceGroup()
                    group.addPlace(place: place)
                    group.setCenter()
                    groups.append(group)
                }
            }
            for group in groups{
                if group.places.count > 1{
                    let pin = PlaceGroupPin(placeGroup: group)
                    addSubview(pin)
                }
                else if let place = group.places.first{
                    let pin = PlacePin(place: place)
                    addSubview(pin)
                    pin.addTarget(self, action: #selector(showPlaceDetails), for: .touchDown)
                }
            }
            
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func getPin(location: Place) -> Pin?{
        for subview in subviews{
            if let pin = subview as? PlacePin, pin.place == location{
                return pin
            }
            if let pin = subview as? PlaceGroupPin, pin.placeGroup.hasPlace(place: location){
                return pin
            }
        }
        return nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            $0 is Pin && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let offset = MapPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint.cgPoint
        for subview in subviews{
            if let placePin = subview as? PlacePin{
                placePin.updatePosition(to: CGPoint(x: (placePin.place.mapPoint.x - offset.x)*scale , y: (placePin.place.mapPoint.y - offset.y)*scale))
            }
            else if let groupPin = subview as? PlaceGroupPin, let center = groupPin.placeGroup.centerPlanetPosition{
                groupPin.updatePosition(to: CGPoint(x: (center.x - offset.x)*scale , y: (center.y - offset.y)*scale))
            }
        }
    }
    
    func updatePlaceState(_ location: Place){
        if let pin = getPin(location: location){
            pin.updateImage()
        }
    }
    
    @objc func showPlaceDetails(_ sender: AnyObject){
        if let pin = sender as? PlacePin{
            delegate?.showPlaceDetails(place: pin.place)
        }
    }
    
}



