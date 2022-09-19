/*
 SwiftyMaps
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol PlaceLayerViewDelegate{
    func showLocationDetails(location: Place)
}

class PlaceLayerView: UIView {
    
    //MainViewController
    var delegate : PlaceLayerViewDelegate? = nil
    
    func setupPins(zoom: Int, offset: CGPoint, scale: CGFloat){
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if zoom == World.maxZoom{
            for location in Places.list{
                let pin = PlacePin(location: location)
                addSubview(pin)
                pin.addTarget(self, action: #selector(showLocationDetails), for: .touchDown)
            }
        }
        else{
            let planetDist = World.zoomScaleToWorld(from: zoom) * 10 // 10m at full zoom
            var groups = Array<PlaceGroup>()
            for location in Places.list{
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
                if group.locations.count > 1{
                    let pin = PlaceGroupPin(locationGroup: group)
                    addSubview(pin)
                }
                else if let location = group.locations.first{
                    let pin = PlacePin(location: location)
                    addSubview(pin)
                    pin.addTarget(self, action: #selector(showLocationDetails), for: .touchDown)
                }
            }
            
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func getPin(location: Place) -> Pin?{
        for subview in subviews{
            if let pin = subview as? PlacePin, pin.location == location{
                return pin
            }
            if let pin = subview as? PlaceGroupPin, pin.locationGroup.hasLocation(location: location){
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
                placePin.updatePosition(to: CGPoint(x: (placePin.location.mapPoint.x - offset.x)*scale , y: (placePin.location.mapPoint.y - offset.y)*scale))
            }
            else if let groupPin = subview as? PlaceGroupPin, let center = groupPin.locationGroup.centerPlanetPosition{
                groupPin.updatePosition(to: CGPoint(x: (center.x - offset.x)*scale , y: (center.y - offset.y)*scale))
            }
        }
    }
    
    func updateLocationState(_ location: Place){
        if let pin = getPin(location: location){
            pin.updateImage()
        }
    }
    
    @objc func showLocationDetails(_ sender: AnyObject){
        if let pin = sender as? PlacePin{
            delegate?.showLocationDetails(location: pin.location)
        }
    }
    
}



